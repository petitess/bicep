param location string
param name string
param tags object = resourceGroup().tags
param snetId string
param pdnszRg string

param featureFlags array

var resourceManagerPlDepoyed = false

resource configStore 'Microsoft.AppConfiguration/configurationStores@2024-05-01' = {
  name: name
  location: location
  sku: {
    name: 'standard'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
    disableLocalAuth: false
    dataPlaneProxy: {
      privateLinkDelegation: 'Enabled'
      authenticationMode: 'Pass-through'
    }
  }
}

resource configurationStoreValues 'Microsoft.AppConfiguration/configurationStores/keyValues@2024-05-01' = [
  for flag in featureFlags: if (resourceManagerPlDepoyed) {
    name: '.appconfig.featureflag~2F${flag.name}'
    parent: configStore
    properties: {
      contentType: 'application/vnd.microsoft.appconfig.ff+json;charset=utf-8'
      value: '{"id": "${flag.name}", "description": "${flag.description}", "enabled": ${flag.enabled}, "conditions": {"client_filters":[]}}'
    }
  }
]

resource pep 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: 'pep-${substring(name, 0, length(name) - 2)}vault-${substring(name, length(name) - 2, 2)}'
  location: location
  tags: tags
  properties: {
    customNetworkInterfaceName: 'nic-pep-${substring(name, 0, length(name) - 2)}vault-${substring(name, length(name) - 2, 2)}'
    privateLinkServiceConnections: [
      {
        name: '${configStore.name}-vault'
        properties: {
          privateLinkServiceId: configStore.id
          groupIds: [
            'configurationStores'
          ]
        }
      }
    ]
    subnet: {
      id: snetId
    }
  }
}

resource dns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = {
  name: 'default'
  parent: pep
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-azconfig-io'
        properties: {
          privateDnsZoneId: resourceId(pdnszRg, 'Microsoft.Network/privateDnsZones', 'privatelink.azconfig.io')
        }
      }
    ]
  }
}
