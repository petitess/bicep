param prefix string
param name string
param tags object = resourceGroup().tags
param location string
param snetId string
param wafId string
param webApplicationFirewallConfiguration object = {}
param sites array = []
param portHttp int = 80
param portHttps int = 443

var frontendPorts = [
  portHttp
  portHttps
]

var listenersHttp = [for site in sites: {
  name: 'listener-${site.name}-http'
  properties: {
    frontendIPConfiguration: {
      id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', name, pip.name)
    }
    frontendPort: {
      id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', name, 'port-${portHttp}')
    }
    hostName: site.hostname
    protocol: 'Http'
    firewallPolicy: empty(site.firewallConfiguration) ? null : {
      id: resourceId('Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies', 'waf-${replace(prefix, 'spoke', site.name)}-01')
    }
  }
}]

var routingRulesHttp = [for (site, i) in sites: {
  name: 'rule-${site.name}-http'
  properties: {
    ruleType: 'Basic'
    priority: 10 + i
    httpListener: {
      id: resourceId('Microsoft.Network/applicationGateways/httpListeners', name, 'listener-${site.name}-http')
    }
    // backendAddressPool: {
    //   id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', name, 'pool-${site.name}')
    // }
    // backendHttpSettings: {
    //   id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', name, 'settings-${site.name}')
    // }
    redirectConfiguration: {
      id: resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', name, 'redirect-${site.name}')
    }
  }
}]

resource waf 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2022-09-01' = [for site in sites: if (!empty(site.firewallConfiguration))  {
  name: 'waf-${replace(prefix, 'spoke', site.name)}-01'
  location: location
  tags: tags
  properties: {
    policySettings: {
      state: webApplicationFirewallConfiguration.enabled ? 'Enabled' : 'Disabled'
      mode: webApplicationFirewallConfiguration.firewallMode
      requestBodyCheck: webApplicationFirewallConfiguration.requestBodyCheck
      maxRequestBodySizeInKb: webApplicationFirewallConfiguration.maxRequestBodySizeInKb
      fileUploadLimitInMb: webApplicationFirewallConfiguration.fileUploadLimitInMb
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: webApplicationFirewallConfiguration.ruleSetType
          ruleSetVersion: webApplicationFirewallConfiguration.ruleSetVersion
          ruleGroupOverrides: site.firewallConfiguration.ruleGroupOverrides
        }
      ]
    }
    customRules: site.firewallConfiguration.customRules
  }
}]

resource pip 'Microsoft.Network/publicIPAddresses@2022-09-01' = {
  name: 'pip-${name}'
  location: location
  tags: tags
  sku:  {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    // dnsSettings: {
    //   domainNameLabel: name
    // }
  }
}

resource agw 'Microsoft.Network/applicationGateways@2022-09-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
    }
    enableHttp2: false
    autoscaleConfiguration: {
      minCapacity: 0
      maxCapacity: 2
    }
    firewallPolicy: {
      id: wafId
    }
    gatewayIPConfigurations: [
      {
        name: 'snet-agw'
        properties: {
          subnet: {
            id: snetId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: pip.name
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.id
          }
        }
      }
      {
        name: 'snet-agw'
        properties: {
          privateIPAddress: '10.100.6.5'
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: snetId
          }
        }
      }
    ]
    frontendPorts: [for frontendPort in frontendPorts: {
      name: 'port-${frontendPort}'
      properties: {
        port: frontendPort
      }
    }]
    backendAddressPools: [for site in sites: {
      name: 'pool-${site.name}'
      properties: {
        backendAddresses: site.backendAddresses
      }
    }]
    backendHttpSettingsCollection: [for site in sites: {
      name: 'settings-${site.name}'
      properties: {
        port: 443 
        protocol: 'Https'
        cookieBasedAffinity: 'Disabled' 
        requestTimeout: 30
        probe: {
          id: resourceId('Microsoft.Network/applicationGateways/probes', name, 'probe-${site.name}')
        }
        pickHostNameFromBackendAddress: false
        hostName: site.hostname
      }
    }]
    requestRoutingRules: routingRulesHttp
    probes: [for site in sites: {
      name: 'probe-${site.name}'
      properties: {
        protocol:'Https'
        path: site.probePath
        interval:5 
        timeout:60
        unhealthyThreshold:20
        pickHostNameFromBackendHttpSettings: true
        match: {
          statusCodes: [
            '200-399'
          ]
        }
      }
    }]
    redirectConfigurations: [for site in sites: {
      name: 'redirect-${site.name}'
      properties: {
        redirectType: 'Permanent'
        // targetListener: {
        //   id: resourceId('Microsoft.Network/applicationGateways/httpListeners', name, 'listener-${site.name}-http')
        // }
        targetUrl: 'http://company.sharepoint.com'
        includePath: true
        includeQueryString: true
        requestRoutingRules: [
          {
            id: resourceId('Microsoft.Network/applicationGateways/requestRoutingRules', name, 'rule-${site.name}-http')
          }
        ]

      }
    }]
    httpListeners: listenersHttp
  }
}
