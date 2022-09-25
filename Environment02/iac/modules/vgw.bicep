targetScope = 'resourceGroup'

param param object
param vgwname string
param subnetid string
param lgwname string
@secure()
param sharedKey string

resource pip 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  name: 'pip-${vgwname}'
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
  name: vgwname
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
      aadTenant: '${param.vgw.aadTenant}/${tenant().tenantId}/'
      aadAudience: param.vgw.aadAudience
      aadIssuer: 'https://sts.windows.net/${tenant().tenantId}/'
    }
    bgpSettings: param.vgw.bgpSettings
    vpnGatewayGeneration: 'Generation1'
  }
}

resource lgw 'Microsoft.Network/localNetworkGateways@2021-08-01' = {
  name: lgwname
  tags: param.tags
  location: param.location
  properties: {
    localNetworkAddressSpace: param.lgw.localNetworkAddressSpace
    gatewayIpAddress: param.lgw.gatewayIpAddress
  }
}

resource con 'Microsoft.Network/connections@2021-08-01' = {
  name: param.con.name
  tags: param.tags
  location: param.location
  properties: {
    virtualNetworkGateway1: {
      id: vgw.id
      properties: {}
    }
    localNetworkGateway2: {
      id: lgw.id
      properties: {
      }
    }
    connectionMode: 'Default'
    connectionType: 'IPsec'
    enableBgp: false
    dpdTimeoutSeconds: 0
    expressRouteGatewayBypass: false
    routingWeight: 0
    sharedKey: sharedKey
    useLocalAzureIpAddress: false
    usePolicyBasedTrafficSelectors: false
  }
}
