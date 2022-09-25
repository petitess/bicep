targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param privateLinkServiceId string
param vnetname string
param subnet string
param filednsid string

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
          groupIds: [
            'file'
          ]
        }
      }
    ]
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetname, subnet) //'${vnet}/subnets/${subnet}'
    }
  }
}

resource dnsgroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = {
  name: 'default'
  parent: pe
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-file-core-windows-net'
        properties: {
          privateDnsZoneId: filednsid
        }
      }
    ]
  }
}

output id string = pe.id
output name string = pe.name
