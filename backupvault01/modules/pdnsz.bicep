param name string
param tags object = resourceGroup().tags
param vnetName string
param vnetId string

var location = 'global'

resource pdnsz 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: name
  location: location
  tags: tags

  resource link 'virtualNetworkLinks' = {
    name: vnetName
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
