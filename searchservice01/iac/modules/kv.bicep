param name string
param environment string
param location string
param subnetId string
param pdnszRg string
param tags object = resourceGroup().tags
param secrets array

var privateEndpointName = 'standards-standard-kv-${environment}-01'

resource kv 'Microsoft.KeyVault/vaults@2022-11-01' = {
  name: name
  location: location
  tags: tags

  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    publicNetworkAccess: 'disabled'
    enableRbacAuthorization: true
    enabledForTemplateDeployment: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
  }

  resource secret 'secrets' = [for secret in secrets: {
    name: secret.name
    properties: {
      value: secret.value
    }
  }]
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-11-01' = {
  name: 'pep-${privateEndpointName}'
  location: location
  properties: {
    customNetworkInterfaceName: 'nic-${privateEndpointName}'
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: kv.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
  }
  tags: tags

  resource privateDNSZoneGroup 'privateDnsZoneGroups@2022-09-01' = {
    name: 'default'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-vaultcore-azure-net'
          properties: {
            privateDnsZoneId: resourceId(pdnszRg, 'Microsoft.Network/privateDnsZones', 'privatelink.vaultcore.azure.net')
          }
        }
      ]
    }
  }
}

output name string = kv.name
