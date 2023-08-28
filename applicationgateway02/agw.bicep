param prefix string
param unique string
param location string
param tags object = resourceGroup().tags
param ruleSetVersion string = '3.2'
param snetName string
param snetId string
param sslCertificates array
param sites array = []
param logId string = ''
param rbacAssigned bool

var name = 'agw-${prefix}-01'
var maxCapacity = 2
var policyName = 'AppGwSslPolicy20220101S'

var listenersHttp = [for (site, i) in sites: {
  name: 'listener-${site.name}-http'
  properties: {
    frontendIPConfiguration: {
      id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', name, pip.name)
    }
    frontendPort: {
      id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', name, 'port-http')
    }
    hostName: site.hostname
    protocol: 'Http'
    firewallPolicy: !contains(site, 'waf') ? null : {
      id: waf[i].id
    }
  }
}]

var listenersHttps = [for (site, i) in sites: {
  name: 'listener-${site.name}-https'
  properties: {
    frontendIPConfiguration: {
      id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', name, pip.name)
    }
    frontendPort: {
      id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', name, 'port-https')
    }
    hostName: site.hostname
    protocol: 'Https'
    sslCertificate: {
      id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', name, site.sslCertificate)
    }
    firewallPolicy: !contains(site, 'waf') ? null : {
      id: waf[i].id
    }
  }
}]

var routingRulesHttp = [for (site, i) in sites: {
  name: 'rule-${site.name}-http'
  properties: {
    ruleType: 'Basic'
    priority: 100 + 200 * i
    httpListener: {
      id: resourceId('Microsoft.Network/applicationGateways/httpListeners', name, 'listener-${site.name}-http')
    }
    redirectConfiguration: {
      id: resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', name, 'redirect-${site.name}')
    }
  }
}]

var routingRulesHttps = [for (site, i) in sites: {
  name: 'rule-${site.name}-https'
  properties: {
    ruleType: 'Basic'
    priority: 200 + 200 * i
    httpListener: {
      id: resourceId('Microsoft.Network/applicationGateways/httpListeners', name, 'listener-${site.name}-https')
    }
    backendAddressPool: {
      id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', name, 'pool-${site.name}')
    }
    backendHttpSettings: {
      id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', name, 'settings-${site.name}')
    }
  }
}]

var sslCertificatesAgw = [for (sslCertificate, i) in sslCertificates: {
      name: sslCertificate
      properties: {
        keyVaultSecretId: 'https://${kv.name}${environment().suffixes.keyvaultDns}/secrets/${sslCertificate}'
      }
    }]

resource kv 'Microsoft.KeyVault/vaults@2023-02-01' existing = if (rbacAssigned) {
  name: 'kv-${prefix}-01'

  resource secret 'secrets' existing = [for sslCertificate in sslCertificates: {
    name: sslCertificate
  }]
}

resource wafDefault 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2023-04-01' = {
  name: 'waf-${replace(prefix, 'waf', 'default')}-01'
  location: location
  tags: tags
  properties: {
    policySettings: {
      state: 'Enabled'
      mode: 'Prevention'
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: ruleSetVersion
        }
      ]
    }
  }
}

resource waf 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2023-04-01' = [for site in sites: if (contains(site, 'waf')) {
  name: 'waf-${replace(prefix, 'waf', site.name)}-01'
  location: location
  tags: tags
  properties: {
    policySettings: {
      state: 'Enabled'
      mode: 'Prevention'
      maxRequestBodySizeInKb: contains(site.waf, 'maxRequestBodySizeInKb') ? site.waf.maxRequestBodySizeInKb : 128
      fileUploadLimitInMb: contains(site.waf, 'fileUploadLimitInMb') ? site.waf.fileUploadLimitInMb : 100
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: ruleSetVersion
          ruleGroupOverrides: site.waf.ruleGroupOverrides
        }
      ]
    }
    customRules: site.waf.customRules
  }
}]

resource id 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'id-${name}'
  location: location
  tags: tags
}

resource pip 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: 'pip-${name}'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: 'pip-${name}-${unique}'
    }
  }
}

resource agw 'Microsoft.Network/applicationGateways@2023-04-01' = {
  name: name
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
    }
    enableHttp2: true
    firewallPolicy: {
      id: wafDefault.id
    }
    autoscaleConfiguration: {
      minCapacity: 0
      maxCapacity: maxCapacity
    }
    sslPolicy: {
      policyType: 'Predefined'
      policyName: policyName
    }
    sslCertificates: rbacAssigned ? sslCertificatesAgw : []
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
    frontendIPConfigurations: [
      {
        name: pip.name
        properties: {
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port-http'
        properties: {
          port: 80
        }
      }
      {
        name: 'port-https'
        properties: {
          port: 443
        }
      }
    ]
    httpListeners: rbacAssigned ? union(listenersHttp, listenersHttps) : listenersHttp
    backendAddressPools: [for site in sites: {
      name: 'pool-${site.name}'
      properties: {
        backendAddresses: site.backendAddresses
      }
    }]
    probes: [for site in sites: {
      name: 'probe-${site.name}'
      properties: {
        protocol: 'Https'
        path: site.probePath
        interval: 30
        timeout: 30
        unhealthyThreshold: 3
        pickHostNameFromBackendHttpSettings: site.pickHostNameFromBackendAddress
        host: site.pickHostNameFromBackendAddress ? null : site.backendAddresses[0].fqdn
        match: {}
      }
    }]
    backendHttpSettingsCollection: [for site in sites: {
      name: 'settings-${site.name}'
      properties: {
        protocol: 'Https'
        port: 443
        cookieBasedAffinity: 'Disabled'
        probe: {
          id: resourceId('Microsoft.Network/applicationGateways/probes', name, 'probe-${site.name}')
        }
        pickHostNameFromBackendAddress: site.pickHostNameFromBackendAddress
        //hostName: site.hostname
        requestTimeout: 120
      }
    }]
    redirectConfigurations: [for site in sites: {
      name: 'redirect-${site.name}'
      properties: {
        redirectType: 'Permanent'
        targetListener: rbacAssigned ? {
          id: resourceId('Microsoft.Network/applicationGateways/httpListeners', name, 'listener-${site.name}-https')
        } : null
        targetUrl: rbacAssigned ? null : 'https://test.xxx'
        includePath: true
        includeQueryString: true
        requestRoutingRules: [
          {
            id: resourceId('Microsoft.Network/applicationGateways/requestRoutingRules', name, 'rule-${site.name}-http')
          }
        ]

      }
    }]
    requestRoutingRules: rbacAssigned ? union(routingRulesHttp, routingRulesHttps) : routingRulesHttp
  }
}

resource diag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logId)) {
  name: 'diag-${name}'
  scope: agw
  properties: {
    workspaceId: logId
    logs: [
      {
        enabled: true
        category: 'ApplicationGatewayAccessLog'
      }
      {
        enabled: true
        category: 'ApplicationGatewayPerformanceLog'
      }
      {
        enabled: true
        category: 'ApplicationGatewayFirewallLog'
      }
    ]
  }
}

output principalId string = id.properties.principalId
