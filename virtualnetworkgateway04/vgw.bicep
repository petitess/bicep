targetScope = 'resourceGroup'

param param object
param name string
param location string
param subnetid string
param bgpSettings object

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

// resource pip2 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
//   name: '${name}-pip2'
//   tags: param.tags
//   location: location
//   sku: {
//     name: 'Standard'
//   }
//   properties: {
//     publicIPAllocationMethod: 'Static'
//   }
// }

resource vgw 'Microsoft.Network/virtualNetworkGateways@2022-07-01' = {
  name: name
  tags: param.tags
  location: location
  properties: {
    enablePrivateIpAddress: false
    vpnGatewayGeneration: 'Generation1'
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: false
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
      // {
      //   name: 'vgwipconfig2'
      //   properties: {
      //     privateIPAllocationMethod: 'Dynamic'
      //     publicIPAddress: {
      //       id: pip2.id
      //     }
      //     subnet: {
      //       id: subnetid
      //     }
      //   }
      // }
    ]
    // bgpSettings: {
    //   asn: bgpSettings.asn
    //   bgpPeeringAddress: bgpSettings.bgpPeeringAddress
    //   peerWeight: bgpSettings.peerWeight
    //   bgpPeeringAddresses: [
    //     {
    //       ipconfigurationId: resourceId('Microsoft.Network/virtualNetworkGateways', '/ipConfigurations', 'vgwipconfig')
    //       customBgpIpAddresses: bgpSettings.customBgpIpAddresses
    //     }
    //     {
    //       ipconfigurationId: resourceId('Microsoft.Network/virtualNetworkGateways', '/ipConfigurations', 'vgwipconfig2')
    //       customBgpIpAddresses: bgpSettings.customBgpIpAddresses
    //     }
    //   ]
    // }
  }
}

output vgwid string = vgw.id
output pip1id string = pip.properties.ipAddress
//output pip2is string = pip2.properties.ipAddress
output z string = vgw.properties.ipConfigurations[0].id
