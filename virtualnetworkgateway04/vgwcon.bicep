targetScope = 'resourceGroup'

param name string
param location string
param virtualNetworkGateway1id string
param localNetworkGateway1id string
param sharedKey string

resource con 'Microsoft.Network/connections@2022-07-01' = {
  name: name
  location: location
  properties: {
    virtualNetworkGateway1: {
      id: virtualNetworkGateway1id
      properties: {}
    }
    localNetworkGateway2: {
      id: localNetworkGateway1id
      properties: {
      }
    }
    connectionMode:  'Default'
    connectionType: 'IPsec'
    enableBgp: true
    dpdTimeoutSeconds: 0
    expressRouteGatewayBypass: false
    routingWeight: 0
    sharedKey: sharedKey
    useLocalAzureIpAddress: false
    usePolicyBasedTrafficSelectors: false
    connectionProtocol: 'IKEv2'
  }
}

