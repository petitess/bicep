targetScope = 'resourceGroup'

param vnetid string

var tags = resourceGroup().tags

resource dns 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'domain.com'
  location: 'global'
  tags: tags
   properties: {
    
   }
}

resource a 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: 'server1.agw'
  parent: dns
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: '10.10.10.250'
      }
    ]
  }
}

resource b 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: 'server2.agw'
  parent: dns
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: '10.10.10.250'
      }
    ]
  }
}

resource x 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'link-dns'
  location: 'global'
  parent: dns
  properties: {
    registrationEnabled: true
    virtualNetwork: {
      id: vnetid
    }
  }
}
