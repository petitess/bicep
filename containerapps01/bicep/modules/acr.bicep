param name string
param location string = resourceGroup().location
param tags object = resourceGroup().tags
param snetPepId string
param rgDns string = ''

resource acr 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'Premium'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    adminUserEnabled: true
    networkRuleSet: {
      defaultAction: 'Allow'
      ipRules: []
    }
    policies: {
      quarantinePolicy: {
        status: 'disabled'
      }
      trustPolicy: {
        type: 'Notary'
        status: 'disabled'
      }
      retentionPolicy: {
        days: 3
        status: 'disabled'
      }
      exportPolicy: {
        status: 'enabled'
      }
      azureADAuthenticationAsArmPolicy: {
        status: 'enabled'
      }
      softDeletePolicy: {
        retentionDays: 7
        status: 'disabled'
      }
    }
    encryption: {
      status: 'disabled'
    }
    dataEndpointEnabled: false
    publicNetworkAccess: 'Enabled'
    networkRuleBypassOptions: 'AzureServices'
    zoneRedundancy: 'Disabled'
    metadataSearch: 'Disabled'
  }
}

resource pep 'Microsoft.Network/privateEndpoints@2024-01-01' = if (!empty(snetPepId)) {
  name: 'pep-${name}'
  location: resourceGroup().location
  tags: resourceGroup().tags
  properties: {
    customNetworkInterfaceName: 'nic-${name}'
    subnet: {
      id: snetPepId
    }
    privateLinkServiceConnections: [
      {
        name: name
        properties: {
          privateLinkServiceId: acr.id
          groupIds: [
            'registry'
          ]
        }
      }
    ]
  }
}

resource dns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-01-01' = if (!empty(snetPepId)) {
  name: 'dns-${name}'
  parent: pep
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'pep'
        properties: {
          privateDnsZoneId: resourceId(rgDns, 'Microsoft.Network/privateDnsZones', 'privatelink.azurecr.io')
        }
      }
    ]
  }
}

output name string = acr.name
output key string = acr.listCredentials().passwords[0].value
