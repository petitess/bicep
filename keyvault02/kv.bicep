param name string
param location string
param tags object = resourceGroup().tags
param sku string
param enabledForDeployment bool
param enabledForTemplateDeployment bool
param enabledForDiskEncryption bool
param enableRbacAuthorization bool
param snetId string
param workspaceId string = ''
param allowedIps array

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: sku
    }
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      ipRules: [
        for ip in allowedIps: {
          value: ip
        }
      ]
    }
    tenantId: subscription().tenantId
    enabledForDeployment: enabledForDeployment
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enableRbacAuthorization: enableRbacAuthorization
  }
}

resource pep 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: 'pep-${substring(name, 0, length(name) - 2)}vault-${substring(name, length(name) - 2, 2)}'
  location: location
  tags: tags
  properties: {
    customNetworkInterfaceName: 'nic-pep-${substring(name, 0, length(name) - 2)}vault-${substring(name, length(name) - 2, 2)}'
    privateLinkServiceConnections: [
      {
        name: '${kv.name}-vault'
        properties: {
          privateLinkServiceId: kv.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
    subnet: {
      id: snetId
    }
  }
}

resource dns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = {
  name: 'default'
  parent: pep
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-vaultcore-azure-net'
        properties: {
          privateDnsZoneId: resourceId('Microsoft.Network/privateDnsZones', 'privatelink.vaultcore.azure.net')
        }
      }
    ]
  }
}

resource diag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' =
  if (!empty(workspaceId)) {
    name: 'diag-kv'
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

output id string = kv.id
output name string = kv.name
output kvUrl string = kv.properties.vaultUri
