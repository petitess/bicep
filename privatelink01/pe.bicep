targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param privateLinkServiceId string
param vnet string
param subnet string

resource pe 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: name
        properties: {
          privateLinkServiceId: privateLinkServiceId

        }
      }
    ]
    subnet: {
      id: '${vnet}/subnets/${subnet}'
    }
  }
}

output id string = pe.id
output name string = pe.name
