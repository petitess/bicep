targetScope = 'resourceGroup'

param param object
param name string
param location string
param subnetid string

resource pip 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: '${name}-pip'
  tags: param.tags
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource vgw 'Microsoft.Network/virtualNetworkGateways@2022-07-01' = {
  name: name
  tags: param.tags
  location: location
  properties: {
    enablePrivateIpAddress: false
    vpnGatewayGeneration: 'Generation1'
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: true
    activeActive: false
    allowRemoteVnetTraffic: true
    allowVirtualWanTraffic: false
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
    ipConfigurations: [
      {
        name: 'vgwipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.id
          }
          subnet: {
            id: subnetid
          }
        }
      }
    ]
    bgpSettings: {
      asn: 60515
      bgpPeeringAddress: '10.25.0.254'
      peerWeight: 0
    }
  }
}

output vgwid string = vgw.id
output pip1id string = pip.properties.ipAddress
