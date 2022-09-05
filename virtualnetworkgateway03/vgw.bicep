targetScope = 'resourceGroup'

param param object
param name string
param subnetid string

resource pip 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
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

resource vgw 'Microsoft.Network/virtualNetworkGateways@2021-08-01' = {
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
    vpnClientConfiguration: {
      vpnClientAddressPool: param.vgw.vpnClientAddressPool
      vpnClientProtocols: [
         'OpenVPN'
      ]
      vpnAuthenticationTypes: [
         'AAD'
      ]
      aadTenant: 'https://login.microsoftonline.com/${tenant().tenantId}/'
      //Azure VPN - Application AD:
      aadAudience: param.vgw.aadAudience
      aadIssuer:'https://sts.windows.net/${tenant().tenantId}/'
    }
    bgpSettings: param.vgw.bgpSettings
    vpnGatewayGeneration: 'Generation1'
    customRoutes: {
      addressPrefixes: [
        '8.8.8.8'
      ]
    }
  }
}
