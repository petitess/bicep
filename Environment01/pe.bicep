targetScope = 'resourceGroup'

param name string
param location string
param groupIds array
param privateLinkServiceId string
param subnetid string

var tags = resourceGroup().tags

resource pe 'Microsoft.Network/privateEndpoints@2022-07-01' = {
  name: name
  tags: tags
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: name
        properties: {
          groupIds: groupIds 
          privateLinkServiceId: privateLinkServiceId
        }
      }
    ]
    subnet: {
      id: subnetid
    }
  }
}
