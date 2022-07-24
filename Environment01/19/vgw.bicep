targetScope = 'resourceGroup'

param location string
param vgateway object
param vgwname string
param subnetid string
param lgwname string

var tags = resourceGroup().tags

resource pip 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  name: 'pip-${vgwname}'
  tags: tags
  location: location
}

resource vgw 'Microsoft.Network/virtualNetworkGateways@2021-08-01' = {
  name: vgwname
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
      vpnClientAddressPool: vgateway.vpnClientAddressPool
      vpnClientProtocols: [
        'IkeV2'
        'SSTP'
      ]
      vpnAuthenticationTypes: [
        'Certificate'
      ]
      vpnClientRootCertificates: vgateway.vpnClientRootCertificates
    }
    bgpSettings: vgateway.bgpSettings
    vpnGatewayGeneration: 'Generation1'
  }
}

resource lgw 'Microsoft.Network/localNetworkGateways@2021-08-01' = {
  name: lgwname
  tags: tags
  location: location
  properties: {
    localNetworkAddressSpace: vgateway.lgw.localNetworkAddressSpace
    gatewayIpAddress: vgateway.lgw.gatewayIpAddress
  }
}

resource con 'Microsoft.Network/connections@2021-08-01' = {
  name: vgateway.con.name
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
    sharedKey: vgateway.con.sharedKey
    useLocalAzureIpAddress: false
    usePolicyBasedTrafficSelectors: false
  }
}
