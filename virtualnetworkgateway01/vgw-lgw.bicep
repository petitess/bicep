targetScope = 'resourceGroup'

param param object
param name string
param tag string
param localAddresses array
param gatewayIpAddress string
param ipsecPolicies array
@secure()
param sharedKey string
param vgwId string



resource lgwCustomers 'Microsoft.Network/localNetworkGateways@2023-06-01' = {
  name: 'lgw-${name}-prod-01'
  tags: union(param.tags, { Customer: tag })
  location: param.location
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: localAddresses
    }
    gatewayIpAddress: gatewayIpAddress
  }
}

resource conCustomers 'Microsoft.Network/connections@2023-06-01' = {
  name: 'con-${name}-sc'
  tags: union(param.tags, { Customer: tag })
  location: param.location
  properties: {
    virtualNetworkGateway1: {
      id: vgwId
      properties: {}
    }
    localNetworkGateway2: {
      id: lgwCustomers.id
      properties: {}
    }
    connectionMode: 'Default'
    connectionType: 'IPsec'
    enableBgp: false
    dpdTimeoutSeconds: 45
    expressRouteGatewayBypass: false
    routingWeight: 0
    sharedKey: sharedKey
    useLocalAzureIpAddress: false
    usePolicyBasedTrafficSelectors: false
    ipsecPolicies: ipsecPolicies
  }
}
