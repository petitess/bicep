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

resource vgw 'Microsoft.Network/virtualNetworkGateways@2022-07-01' = {
  name: name
  tags: param.tags
  location: location
  properties: {
    enablePrivateIpAddress: false
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
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: true
    activeActive: false
    bgpSettings: {
      asn: 65515
      bgpPeeringAddress: '10.25.0.254'
    }
    
    //bgpSettings
    vpnGatewayGeneration: 'Generation1'
  }
}

output vgwid string = vgw.id
