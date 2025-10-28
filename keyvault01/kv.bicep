param location string
param name string
param tags object = resourceGroup().tags
param workspaceId string?
param allowIps array
param publicNetworkAccess 'Allow' | 'Deny' = 'Allow'
param dnsRg string
param ipAddress string
param enablePurgeProtection bool = false
param snetEndpoint string
param softDeleteRetentionInDays int = 7
param rbac {
  role: ('Key Vault Administrator' | 'Key Vault Secrets User')
  principalId: string
  principalType: ('Device' | 'ForeignGroup' | 'Group' | 'ServicePrincipal' | 'User')?
}[] = []

var rolesList = {
  'Key Vault Administrator': '00482a5a-887f-4fb3-b363-3b7fe8e74483'
  'Key Vault Secrets User': '4633458b-17de-408a-b874-0445c86b69e6'
}
var tenantId = subscription().tenantId
var sku = 'standard'

resource kv 'Microsoft.KeyVault/vaults@2025-05-01' = {
  name: name
  tags: tags
  location: location
  properties: {
    sku: {
      family: 'A'
      name: sku
    }
    tenantId: tenantId
    enableSoftDelete: true
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    enableRbacAuthorization: true
    enablePurgeProtection: enablePurgeProtection
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: publicNetworkAccess
      bypass: 'AzureServices'
      ipRules: [
        for ip in allowIps: {
          value: '${ip}/32'
        }
      ]
    }
  }
}

resource key 'Microsoft.KeyVault/vaults/keys@2025-05-01' = {
  name: 'KeyRSA3072'
  parent: kv
  properties: {
    kty: 'RSA'
    keySize: 3072
  }
}

resource Pekv 'Microsoft.Network/privateEndpoints@2024-10-01' = {
  name: 'pep-${kv.name}'
  location: location
  tags: tags
  properties: {
    customNetworkInterfaceName: 'nic-${kv.name}'
    subnet: {
      id: snetEndpoint
    }
    ipConfigurations: ipAddress != ''
      ? [
          {
            name: 'config'
            properties: {
              groupId: 'vault'
              memberName: 'default'
              privateIPAddress: ipAddress
            }
          }
        ]
      : []
    privateLinkServiceConnections: [
      {
        name: kv.name
        properties: {
          privateLinkServiceId: kv.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
  }
}

resource pdnszg 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-10-01' = {
  name: 'default'
  parent: Pekv
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-vaultcore-azure-net'
        properties: {
          privateDnsZoneId: resourceId(dnsRg, 'Microsoft.Network/privateDnsZones', 'privatelink.vaultcore.azure.net')
        }
      }
    ]
  }
}

resource rbacR 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (r, i) in rbac: if (rbac != []) {
    name: guid(resourceGroup().id, r.principalId, r.role, string(i))
    properties: {
      principalId: r.principalId
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleAssignments', rolesList[r.role])
      principalType: r.?principalType ?? 'ServicePrincipal'
    }
  }
]

resource diag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (workspaceId != null) {
  scope: kv
  name: 'diag-${kv.name}'
  properties: {
    workspaceId: workspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
      }
    ]
  }
}

output kvId string = kv.id
output kvName string = kv.name
output kvUrl string = kv.properties.vaultUri
output keyUrl string = key.properties.keyUriWithVersion
