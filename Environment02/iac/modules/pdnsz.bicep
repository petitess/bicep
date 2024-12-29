param name string
param tags object = resourceGroup().tags
param vnetId string

var location = 'global'

resource pdnsz 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: name
  location: location
  tags: tags

  resource link 'virtualNetworkLinks' = {
    name: 'pdnsz-${split(name, '.')[1]}'
    location: location
    tags: tags
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: vnetId
      }
    }
  }
}
