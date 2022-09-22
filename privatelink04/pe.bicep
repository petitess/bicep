targetScope = 'resourceGroup'

param name string
param location string
param privateLinkServiceId string
param subnetid string

var tags = resourceGroup().tags

resource pe 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: name
  location: location
  tags: tags
  properties: {
   privateLinkServiceConnections: [
    {
      name: 'connection01'
      properties: {
        privateLinkServiceId: privateLinkServiceId
        groupIds: [
          'sqlserver'
        ]
      }
    }
   ] 
   subnet: {
    id: subnetid
   }
  }
}
