param name string
param location string
param tags object
param snetPepId string
param privateDnsZoneId string
param virtualNetworkRules { id: string }[] = []
param workspaceId string?
param ipAddress string
param allowIPs array

param rbac ({
  role: (
    | 'Key Vault Reader'
    | 'Key Vault Secrets Officer'
    | 'Key Vault Secrets User'
    | 'Key Vault Administrator')
  principalId: string
})[]

var rolesList = {
  'Key Vault Reader': '21090545-7ca7-4776-b22c-e363652d74d2'
  'Key Vault Secrets Officer': 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
  'Key Vault Secrets User': '4633458b-17de-408a-b874-0445c86b69e6'
  'Key Vault Administrator': '00482a5a-887f-4fb3-b363-3b7fe8e74483'
}

resource kv 'Microsoft.KeyVault/vaults@2024-04-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenant().tenantId
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      virtualNetworkRules: virtualNetworkRules
      ipRules: [for i in allowIPs: {
        value: i
      }]
    }
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: true
    publicNetworkAccess: 'Enabled'
  }
}

resource secret1 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' = {
  name: 'adminUsername'
  tags: tags
  parent: kv
  properties: {
    value: 'azadmin'
  }
}

resource pep 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: 'pep-${name}'
  location: location
  tags: tags
  properties: {
    customNetworkInterfaceName: 'nic-${name}'
    privateLinkServiceConnections: [
      {
        name: 'A'
        properties: {
          privateLinkServiceId: kv.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
    subnet: {
      id: snetPepId
    }
    ipConfigurations: [
      {
        name: 'config'
        properties: {
          privateIPAddress: ipAddress
          groupId: 'vault'
          memberName: 'default'
        }
      }
    ]
  }
}

resource pepDns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = {
  name: 'default'
  parent: pep
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-vaultcore-azure-net'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

resource diag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(workspaceId)) {
  name: 'diag-${name}'
  scope: kv
  properties: {
    workspaceId: workspaceId
    logs: [
      for c in items({ AuditEvent: true, AzurePolicyEvaluationDetails: true }): {
        category: c.key
        enabled: c.value
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
      principalType: 'ServicePrincipal'
    }
  }
]

output id string = kv.id
output name string = kv.name
output kvUrl string = kv.properties.vaultUri
