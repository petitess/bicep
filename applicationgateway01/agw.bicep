targetScope = 'resourceGroup'

param name string
param location string
param subnetid string

var tags = resourceGroup().tags

resource agw 'Microsoft.Network/applicationGateways@2022-01-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    enableHttp2: false
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
      capacity: 2
    }
    gatewayIPConfigurations: [
      {
        name: 'agwipconf'
        properties: {
          subnet: {
            id: subnetid
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'agwpip'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'http'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'Pool01'
        properties:{}
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'settings01'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
        }
      }
    ]
    httpListeners: [
      {
        name: 'listner01'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', name, 'agwpip')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', name, 'http')
          }
          protocol: 'Http'
          requireServerNameIndication: false
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'RTrule01'
        properties: {
          ruleType: 'Basic'
          priority: 500
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', name, 'listner01')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', name, 'Pool01')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', name, 'settings01')
          }
        }
      }
    ]
  }
}

resource pip 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: 'pip-${name}'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

output backendpoolid string = agw.properties.backendAddressPools[0].id
