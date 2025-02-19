param name string
param location string
param tags object = resourceGroup().tags
param snetId string
param pdnszRg string

var pepWorksTheFirstTimeOnly = false

resource ampl 'Microsoft.Authorization/resourceManagementPrivateLinks@2020-05-01' = {
  name: name
  location: location
}

resource pep 'Microsoft.Network/privateEndpoints@2024-05-01' = if (pepWorksTheFirstTimeOnly) {
  name: 'pep-${name}'
  location: location
  tags: tags
  properties: {
    customNetworkInterfaceName: 'nic-${name}'
    privateLinkServiceConnections: [
      {
        name: 'pl-connection'
        properties: {
          privateLinkServiceId: ampl.id
          groupIds: [
            'ResourceManagement'
          ]
        }
      }
    ]
    subnet: {
      id: snetId
    }
  }
}

resource dns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = if (pepWorksTheFirstTimeOnly) {
  name: 'default'
  parent: pep
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-azure-com'
        properties: {
          privateDnsZoneId: resourceId(pdnszRg, 'Microsoft.Network/privateDnsZones', 'privatelink.azure.com')
        }
      }
    ]
  }
}

output amplId string = ampl.id
