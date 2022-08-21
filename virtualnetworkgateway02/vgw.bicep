targetScope = 'resourceGroup'

param param object
param name string
param location string
param subnetid string
param bgpSettings object

resource pip 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  name: 'pip-${name}'
  tags: param.tags
  location: location
  sku: {
      name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource vgw 'Microsoft.Network/virtualNetworkGateways@2021-08-01' = {
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
    enableBgp: false
    activeActive: false
    bgpSettings: bgpSettings
    vpnGatewayGeneration: 'Generation1'
  }
}

output vgwid string = vgw.id
