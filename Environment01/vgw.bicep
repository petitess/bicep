targetScope = 'resourceGroup'

param location string
param param object
param vgwName string
param subnetId string
param env string

var tags = resourceGroup().tags

resource pip 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: 'pip-${vgwName}'
  tags: tags
  location: location
}

resource vgw 'Microsoft.Network/virtualNetworkGateways@2023-04-01' = {
  name: vgwName
  tags: tags
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
            id: subnetId
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
        'IkeV2'
        'SSTP'
      ]
      vpnAuthenticationTypes: [
        'Certificate'
      ]
      vpnClientRootCertificates: param.vgw.vpnClientRootCertificates
    }
    bgpSettings: param.vgw.bgpSettings
    vpnGatewayGeneration: 'Generation1'
  }
}

resource lgw 'Microsoft.Network/localNetworkGateways@2022-07-01' = {
  name: 'lgw-${env}-01'
  tags: tags
  location: location
  properties: {
    localNetworkAddressSpace: param.vgw.lgw.localNetworkAddressSpace
    gatewayIpAddress: param.vgw.lgw.gatewayIpAddress
  }
}

resource con 'Microsoft.Network/connections@2023-04-01' = {
  name: param.vgw.con.name
  location: location
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
    sharedKey: param.vgw.con.sharedKey
    useLocalAzureIpAddress: false
    usePolicyBasedTrafficSelectors: false
  }
}
