targetScope = 'resourceGroup'

param vnet01existingname string
param vnet02existingname string
param vnet02rg string

resource vnet01existing 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: vnet01existingname
}

resource vnet02existing 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: vnet02existingname
  scope: resourceGroup(vnet02rg)
}

resource peering1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-03-01' = {
  name: 'peer-vnet01-vnet02'
  parent: vnet01existing
  properties: {
    remoteVirtualNetwork: {
      id: vnet02existing.id
    }
    allowForwardedTraffic: true
    allowGatewayTransit: true
    allowVirtualNetworkAccess: true
    useRemoteGateways: false
    remoteAddressSpace: {
      addressPrefixes:[
        '10.20.0.0/16'
      ]
    }
  }
}
