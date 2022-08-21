targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param privateLinkServiceId string
param groupIds array
param vnet string
param subnet string

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
          groupIds: groupIds
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
        name: 'privatelink-file-core-windows-net'
        properties: {
          privateDnsZoneId: dns.id
        }
      }
    ]
  }
}

resource dns 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.file.core.windows.net'
  location: 'global'
  tags: tags
}

resource link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'link01'
  parent: dns
  location: 'global'
  tags: tags
  properties: {
    registrationEnabled: false
    virtualNetwork:{
      id: vnet
    }
  }
}

output id string = pe.id
output name string = pe.name
