param name string = 'dnspr01'
param vnetId string
param snetId string
param inboundIp string

resource dnspr 'Microsoft.Network/dnsResolvers@2023-07-01-preview' = {
  name: name
  location: resourceGroup().location
  properties: {
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource inbound 'Microsoft.Network/dnsResolvers/inboundEndpoints@2023-07-01-preview' = {
  name: 'in-snet-dnspr'
  parent: dnspr
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        privateIpAllocationMethod: 'Static'
        privateIpAddress: inboundIp
        subnet: {
          id: snetId
        }
      }
    ]
  }
}
