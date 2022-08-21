targetScope = 'resourceGroup'

param vnet01existingname string
param vnet02existingname string
param vnet01rg string

resource vnet01existing 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: vnet01existingname
  scope: resourceGroup(vnet01rg)
}

resource vnet02existing 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: vnet02existingname
}

resource peering1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-03-01' = {
  name: 'peer-vnet02-vnet01'
  parent: vnet02existing
  properties: {
    remoteVirtualNetwork: {
      id: vnet01existing.id
    }
    allowForwardedTraffic: true
    allowGatewayTransit: false
    allowVirtualNetworkAccess: true
    useRemoteGateways: false
    remoteAddressSpace: {
      addressPrefixes:[
        '10.10.0.0/16'
      ]
    }
  }
}
