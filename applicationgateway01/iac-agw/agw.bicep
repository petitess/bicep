targetScope = 'resourceGroup'

param env string
param location string
param rgVnetName string
param vnetName string
param snetName string
param agw object
param sites array
// param LogId string

@secure()
param certdata string
param pass string

var siteName = [for site in sites: site.public ? 'ext-${site.hostname}' : site.hostname]
var tags = resourceGroup().tags
var snetId = resourceId(rgVnetName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, snetName)

var listenersHttp = [
  for (site, i) in sites: {
    name: '${siteName[i]}-HTTPlistener'
    properties: {
      frontendIPConfiguration: site.public
        ? {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', agw.name, 'public-ip')
          }
        : {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', agw.name, 'private-ip')
          }
      frontendPort: {
        id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', agw.name, 'frontendPort80')
      }
      hostName: site.hostname
      protocol: 'Http'
      firewallPolicy: !contains(site, 'waf')
        ? null
        : {
            id: waf[i].id
          }
    }
  }
]

var listenersHttps = [
  for (site, i) in sites: {
    name: '${siteName[i]}-HTTPSlistener'
    properties: {
      frontendIPConfiguration: site.public
        ? {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', agw.name, 'public-ip')
          }
        : {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', agw.name, 'private-ip')
          }
      frontendPort: {
        id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', agw.name, 'frontendPort443')
      }
      hostName: site.hostname
      protocol: 'Https'
      requireServerNameIndication: true
      sslCertificate: {
        id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', agw.name, agw.sslCertificates[0])
      }
      firewallPolicy: !contains(site, 'waf')
        ? null
        : {
            id: waf[i].id
          }
    }
  }
]

var routingRulesHttp = [
  for (site, i) in sites: {
    name: '${siteName[i]}-RedirectRule'
    properties: {
      ruleType: 'Basic'
      priority: 10 + 20 * i
      httpListener: {
        id: resourceId('Microsoft.Network/applicationGateways/httpListeners', agw.name, '${siteName[i]}-HTTPlistener')
      }
      redirectConfiguration: {
        id: resourceId(
          'Microsoft.Network/applicationGateways/redirectConfigurations',
          agw.name,
          'redirectTo-${siteName[i]}-HTTPSlistener'
        )
      }
    }
  }
]

var routingRulesHttps = [
  for (site, i) in sites: {
    name: '${siteName[i]}-Rule'
    properties: {
      ruleType: 'Basic'
      priority: site.priority
      httpListener: {
        id: resourceId('Microsoft.Network/applicationGateways/httpListeners', agw.name, '${siteName[i]}-HTTPSlistener')
      }
      backendAddressPool: {
        id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', agw.name, 'Pool-${siteName[i]}')
      }
      backendHttpSettings: {
        id: resourceId(
          'Microsoft.Network/applicationGateways/backendHttpSettingsCollection',
          agw.name,
          '${siteName[i]}-HTTPsetting'
        )
      }
    }
  }
]

var redirectHttp = [
  for (site, i) in sites: {
    name: 'redirectTo-${siteName[i]}-HTTPSlistener'
    properties: {
      redirectType: 'Permanent'
      targetListener: {
        id: resourceId('Microsoft.Network/applicationGateways/httpListeners', agw.name, '${siteName[i]}-HTTPSlistener')
      }
      includePath: contains(site, 'redirectUrl') ? null : true
      includeQueryString: contains(site, 'redirectUrl') ? null : true
      requestRoutingRules: [
        {
          id: resourceId(
            'Microsoft.Network/applicationGateways/requestRoutingRules',
            agw.name,
            '${siteName[i]}-RedirectRule'
          )
        }
      ]
    }
  }
]

resource pip 'Microsoft.Network/publicIPAddresses@2025-05-01' = {
  name: 'pip-${agw.name}'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: agw.name
    }
  }
}

resource waf 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2025-05-01' = [
  for (site, i) in sites: if (contains(site, 'waf')) {
    name: site.public ? 'waf-public-${site.hostname}' : 'waf-${site.hostname}'
    location: location
    tags: tags
    properties: {
      policySettings: {
        state: 'Enabled'
        mode: site.waf.mode
        requestBodyCheck: site.waf.requestBodyCheck
        maxRequestBodySizeInKb: contains(site.waf.managedRules, 'maxRequestBodySizeInKb')
          ? site.waf.maxRequestBodySizeInKb
          : 128
        fileUploadLimitInMb: contains(site.waf.managedRules, 'fileUploadLimitInMb') ? site.waf.fileUploadLimitInMb : 100
        fileUploadEnforcement: site.waf.requestBodyCheck ? true : false
        requestBodyEnforcement: site.waf.requestBodyCheck ? true : false
      }
      managedRules: site.waf.managedRules
      customRules: site.waf.customRules
    }
  }
]

resource wafdefault 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2025-05-01' = {
  name: 'waf-policy-default-${env}'
  location: location
  properties: {
    customRules: []
    policySettings: {
      requestBodyCheck: true
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 100
      state: 'Enabled'
      mode: 'Prevention'
      requestBodyInspectLimitInKB: 128
      fileUploadEnforcement: true
      requestBodyEnforcement: true
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.2'
          ruleGroupOverrides: []
        }
      ]
      exclusions: []
    }
  }
}

resource id 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-05-31-preview' = {
  name: 'id-${agw.name}'
  location: location
  tags: tags
}

resource AGW 'Microsoft.Network/applicationGateways@2025-05-01' = {
  name: agw.name
  location: location
  tags: tags

  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${id.id}': {}
    }
  }

  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      capacity: 1
    }
    firewallPolicy: {
      id: wafdefault.id
    }

    enableHttp2: true
    gatewayIPConfigurations: [
      {
        name: snetName
        properties: {
          subnet: {
            id: snetId
          }
        }
      }
    ]
    sslCertificates: [
      for (sslCertificate, i) in agw.sslCertificates: {
        name: sslCertificate
        properties: {
          data: certdata
          password: pass
        }
      }
    ]
    trustedRootCertificates: []
    frontendIPConfigurations: [
      {
        name: 'public-ip'
        properties: {
          publicIPAddress: {
            id: pip.id
          }
        }
      }
      {
        name: 'private-ip'
        properties: {
          privateIPAddress: agw.privateip
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: snetId
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'frontendPort443'
        properties: {
          port: 443
        }
      }
      {
        name: 'frontendPort80'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      for (site, i) in sites: {
        name: 'Pool-${siteName[i]}'
        properties: {
          backendAddresses: site.backendAddresses
        }
      }
    ]
    backendHttpSettingsCollection: [
      for (site, i) in sites: {
        name: '${siteName[i]}-HTTPsetting'
        properties: {
          protocol: site.protocol
          port: site.port
          cookieBasedAffinity: 'Disabled'
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', agw.name, '${siteName[i]}-Probe')
          }
          pickHostNameFromBackendAddress: site.pickHostNameFromBackendAddress
          probeEnabled: true
          requestTimeout: 120
        }
      }
    ]
    httpListeners: union(listenersHttp, listenersHttps)
    probes: [
      for (site, i) in sites: {
        name: '${siteName[i]}-Probe'
        properties: {
          protocol: 'Https'
          path: site.probePath
          interval: 30
          timeout: 120
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: false
          host: site.?probeHost ?? site.hostname
          match: {
            statusCodes: site.probeStatus
          }
        }
      }
    ]
    requestRoutingRules: union(routingRulesHttp, routingRulesHttps)
    redirectConfigurations: redirectHttp
  }
}

//OBS! If you enable diagnositc with bicep AzureDiagnostic logs stop working

// resource diagagw 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
//   name: 'diag-${agw.name}'
//   scope: AGW
//   properties: {
//     workspaceId: LogId
//     logAnalyticsDestinationType: 'Dedicated'
//     logs: [
//       {
//         categoryGroup: 'allLogs'
//         enabled: true
//       }
//     ]
//   }
// }
