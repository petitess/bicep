targetScope = 'resourceGroup'

param name string
param location string
param param object

var tags = resourceGroup().tags

resource wan 'Microsoft.Network/virtualWans@2022-01-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    type: param.type
    disableVpnEncryption: false
    allowVnetToVnetTraffic: true
    allowBranchToBranchTraffic: true
  }
}

resource hub 'Microsoft.Network/virtualHubs@2022-01-01' = {
  name: 'hub-${name}'
  location: location
  tags: tags
  properties: {
    sku: param.sku
    addressPrefix: param.addressPrefix
    allowBranchToBranchTraffic: true
    virtualWan: {
      id: wan.id
    }
    virtualRouterAutoScaleConfiguration: {
      minCapacity: 2
    }
  }
}

resource gw 'Microsoft.Network/vpnGateways@2022-01-01' = {
  name: 'vgw-${name}'
  location: location
  tags: tags
  properties: {
    vpnGatewayScaleUnit: 1
    virtualHub: {
      id: hub.id
    }
    isRoutingPreferenceInternet: false
    bgpSettings: {
      asn: 65515
    }
  }
}

resource P2S 'Microsoft.Network/p2svpnGateways@2022-01-01' = {
  name: 'P2S-${name}'
  location: location
  tags: tags
  properties: {
    virtualHub: {
       id: hub.id
    }
    isRoutingPreferenceInternet: false
    customDnsServers: []
    vpnGatewayScaleUnit: 1
    vpnServerConfiguration: {
      id: P2Sconfig.id
    }
    p2SConnectionConfigurations: param.p2SConnectionConfigurations
  }
}

resource P2Sconfig 'Microsoft.Network/vpnServerConfigurations@2022-01-01' = {
  name: 'P2Sconfig'
  location: location
  tags: tags
  properties: {
    vpnProtocols: [
      'IkeV2'
    ]
    vpnAuthenticationTypes: [
      'Certificate'
    ]
    vpnClientRootCertificates: param.vpnClientRootCertificates
  }
}
