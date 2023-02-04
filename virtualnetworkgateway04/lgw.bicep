targetScope = 'resourceGroup'

param name string
param location string
param gatewayIpAddress string
param addressPrefixes array
// param asn int
// param peerWeight int
// param bgpPeeringAddress string

var tags = resourceGroup().tags

resource lgw 'Microsoft.Network/localNetworkGateways@2022-07-01' = {
  name: name
  tags: tags
  location: location
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: addressPrefixes
    }
    // bgpSettings: {
    //   asn: asn
    //   peerWeight: peerWeight
    //   bgpPeeringAddress: bgpPeeringAddress
    //   bgpPeeringAddresses: [
    //     {
    //       ipconfigurationId: resourceId('Microsoft.Network/virtualNetworkGateways', '/ipConfigurations/vgwipconfig')
    //       customBgpIpAddresses: []
    //     }
    //   ]
    // }
    gatewayIpAddress: gatewayIpAddress
  }
}

output id string = lgw.id
