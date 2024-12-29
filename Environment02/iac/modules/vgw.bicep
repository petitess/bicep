targetScope = 'resourceGroup'

param vgw object
param name string
param vnetName string
param location string

resource pip 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: 'pip-${name}'
  tags: resourceGroup().tags
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource vgwR 'Microsoft.Network/virtualNetworkGateways@2024-05-01' = {
  name: name
  tags: resourceGroup().tags
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
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, 'GatewaySubnet')
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
      vpnClientAddressPool: vgw.vpnClientAddressPool
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

resource lock1 'Microsoft.Authorization/locks@2020-05-01' = if (false) {
  name: 'dontdelete'
  scope: pip
  properties: {
    level: 'CanNotDelete'
  }
}

output id string = vgwR.id
