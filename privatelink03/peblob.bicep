targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param privateLinkServiceId string
param vnet string
param subnet string
param blobdnsid string

resource pe 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: name
        properties: {
          privateLinkServiceId: privateLinkServiceId
          groupIds: [
            'blob'
          ]
        }
      }
    ]
    subnet: {
      id: '${vnet}/subnets/${subnet}'
    }
  }
}

resource dnsgroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = {
  name: 'default'
  parent: pe
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-blob-core-windows-net'
        properties: {
          privateDnsZoneId: blobdnsid
        }
      }
    ]
  }
}

output id string = pe.id
output name string = pe.name
