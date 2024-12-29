targetScope = 'resourceGroup'

param location string
param name string
param tag string
param localAddresses array
param gatewayIpAddress string
param ipsecPolicies array
param vgwId string
param kvRg string
param kvName string

var sharedKey = 'A1.${uniqueString(subscription().id, resourceGroup().name, name)}2025'

resource lgwCustomers 'Microsoft.Network/localNetworkGateways@2024-05-01' = {
  name: 'lgw-${name}-prod-01'
  tags: union(resourceGroup().tags , { Customer: tag })
  location: location
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: localAddresses
    }
    gatewayIpAddress: gatewayIpAddress
  }
}

resource conCustomers 'Microsoft.Network/connections@2024-05-01' = {
  name: 'con-${name}-sc'
  tags: union(resourceGroup().tags , { Customer: tag })
  location: location
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

module sec 'vmsec.bicep' = {
  name: '${name}-sec'
  scope: resourceGroup(kvRg)
  params: {
    kvName: kvName
    name: 'con-${name}-sc'
    pass: sharedKey
  }
}

resource lock1 'Microsoft.Authorization/locks@2020-05-01' = if (false) {
  name: 'dontdelete'
  scope: lgwCustomers
  properties: {
    level: 'CanNotDelete'
  }
}

resource lock2 'Microsoft.Authorization/locks@2020-05-01' = if (false) {
  name: 'dontdelete'
  scope: conCustomers
  properties: {
    level: 'CanNotDelete'
  }
}
