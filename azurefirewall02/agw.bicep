targetScope = 'resourceGroup'

param name string
param location string
param subnetid string

param vnetname string = 'vnet-infra-dev-01'
param subnetname string = 'snet-agw-test-01'

var tags = resourceGroup().tags

resource agw 'Microsoft.Network/applicationGateways@2022-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    firewallPolicy: {
      id: policy.id
    }
    enableHttp2: false
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
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
          publicIPAddress: {
            id: pip.id
          }
        }
      }
      {
        name: 'agwip'
        properties: {
          privateIPAddress: replace(reference(resourceId('Microsoft.Network/virtualNetworks/subnets', vnetname, subnetname), '2022-07-01').addressPrefix, '.0/24', '.250')
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: subnetid
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
        properties:{
        }
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
          affinityCookieName: 'ApplicationGatewayAffinity'
          requestTimeout: 20
        }
      }
    ]
    httpListeners: [
      {
        name: 'listner01'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', name, 'agwip')
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


resource pip 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
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

resource policy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2022-07-01' = {
  name: 'waf-${name}'
  location: location
  tags: tags
  properties: {
    policySettings: {
      requestBodyCheck: true
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 100
      state: 'Enabled'
      mode: 'Prevention'
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.2'
          ruleGroupOverrides: []
        }
      ]
    }
    customRules: [
      {
        name: 'Allow-Sweden'
        priority: 1
        ruleType: 'MatchRule'
        action: 'Allow'
        matchConditions: [
          {
            matchVariables: [
              {
                variableName: 'RemoteAddr'
              }
            ]
            operator: 'GeoMatch'
            negationConditon: false
            matchValues: [
              'SE'
            ]
            transforms: []
          }
        ]
      }
      {
        name: 'Block-China'
        priority: 2
        ruleType: 'MatchRule'
        action: 'Block'
        matchConditions: [
          {
            matchVariables: [
              {
                variableName: 'RemoteAddr'
              }
            ]
            operator: 'GeoMatch'
            negationConditon: false
            matchValues: [
              'CN'
            ]
            transforms: []
          }
        ]
      }
    ]
  }
}

output backendpool1id string = agw.properties.backendAddressPools[0].id
