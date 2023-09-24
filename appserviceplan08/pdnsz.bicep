param name string
param tags object = resourceGroup().tags
param vnetId string

var location = 'global'

resource pdnsz 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: name
  location: location
  tags: tags

  resource linkProd 'virtualNetworkLinks' = {
    name: 'vnet01'
    location: location
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: vnetId
      }
    }
  }
}
