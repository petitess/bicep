targetScope = 'resourceGroup'

param param object
param name string
param snetId string

resource pip 'Microsoft.Network/publicIPAddresses@2023-06-01' = {
  name: 'pip-${name}'
  tags: param.tags
  location: param.location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource vgw 'Microsoft.Network/virtualNetworkGateways@2023-06-01' = {
  name: name
  tags: param.tags
  location: param.location
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
            id: snetId
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
    vpnClientConfiguration: {
      vpnClientAddressPool: param.vgw.vpnClientAddressPool
      vpnClientProtocols: [
        'OpenVPN'
      ]
      vpnAuthenticationTypes: [
        'AAD'
      ]
      aadTenant: '${environment().authentication.loginEndpoint}${tenant().tenantId}/'
      aadAudience: '41b23e61-6c1e-4545-b367-cd054e0ed4b4'
      aadIssuer: 'https://sts.windows.net/${tenant().tenantId}/'
    }
    vpnGatewayGeneration: 'Generation1'
  }
}

output id string = vgw.id
