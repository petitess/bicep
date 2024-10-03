targetScope = 'subscription'

param prefix string
param unique string
param location string
param tags object
param ruleSetVersion string = '3.2'
param snetName string
param privateIPAddress string
param snetId string
param sslCertificates array
param sites array = []
param pathRules array = []
param logId string
param prefixCert string

var name = 'agw-${prefix}-01'
var policyName = 'AppGwSslPolicy20220101'

var listenersHttp = [
  for (site, i) in sites: {
    name: 'listener-${site.name}-http'
    properties: {
      frontendIPConfiguration: site.privateListener
        ? {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', name, snetName)
          }
        : {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', name, pip.name)
          }
      frontendPort: {
        id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', name, 'port-http')
      }
      hostName: site.?hostName ?? null
      hostNames: site.?hostNames ?? null
      protocol: 'Http'
      firewallPolicy: !contains(site, 'waf')
        ? null
        : {
            id: resourceId(rg.name, 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies', 'waf-${replace(prefix, 'waf', site.name)}-01') //waf[i].outputs.resourceId
          }
    }
  }
]

var listenersHttps = [
  for (site, i) in sites: {
    name: 'listener-${site.name}-https'
    properties: {
      frontendIPConfiguration: site.privateListener
        ? {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', name, snetName)
          }
        : {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', name, pip.name)
          }
      frontendPort: {
        id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', name, 'port-https')
      }
      hostName: site.?hostName ?? null
      hostNames: site.?hostNames ?? null
      protocol: 'Https'
      sslCertificate: {
        id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', name, site.sslCertificate)
      }
      firewallPolicy: !contains(site, 'waf')
        ? null
        : {
            id: resourceId(rg.name, 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies', 'waf-${replace(prefix, 'waf', site.name)}-01') //waf[i].outputs.resourceId
          }
    }
  }
]

var backendAddressPoolsSites = [
  for site in filter(sites, site => !contains(site, 'redirection')): {
    name: 'pool-${site.name}'
    properties: {
      backendAddresses: site.?backendAddresses ?? []
    }
  }
]

var backendAddressPoolsPaths = [
  for rule in pathRules: {
    name: 'pool-${rule.site}-${rule.name}'
    properties: {
      backendAddresses: rule.backendAddresses
    }
  }
]

var backendHttpSettingsCollectionSites = [
  for site in filter(sites, site => !contains(site, 'redirection')): {
    name: 'settings-${site.name}'
    properties: {
      protocol: site.?backendSettingsProtocol ?? 'Https'
      port: contains(site, 'backendSettingsProtocol') && site.backendSettingsProtocol == 'Http' ? 80 : 443
      cookieBasedAffinity: 'Disabled'
      probe: contains(site, 'backendAddresses')
        ? {
            id: resourceId('Microsoft.Network/applicationGateways/probes', name, 'probe-${site.name}')
          }
        : null
      pickHostNameFromBackendAddress: contains(site, 'backendAddresses') ? site.pickHostNameFromBackendAddress : false
      path: site.?overrideBackendPath ?? null
      requestTimeout: 120
    }
  }
]

var backendHttpSettingsCollectionPaths = [
  for rule in pathRules: {
    name: 'settings-${rule.site}-${rule.name}'
    properties: {
      protocol: rule.?backendSettingsProtocol ?? 'Https'
      port: contains(rule, 'backendSettingsProtocol') && rule.backendSettingsProtocol == 'Http' ? 80 : 443
      cookieBasedAffinity: 'Disabled'
      probe: {
        id: resourceId('Microsoft.Network/applicationGateways/probes', name, 'probe-${rule.site}-${rule.name}')
      }
      pickHostNameFromBackendAddress: rule.pickHostNameFromBackendAddress
      path: rule.?overrideBackendPath ?? null
      requestTimeout: 120
    }
  }
]

var routingRulesHttp = [
  for (site, i) in sites: {
    name: 'rule-${site.name}-http'
    properties: {
      ruleType: 'Basic'
      priority: 100 + 200 * i
      httpListener: {
        id: resourceId('Microsoft.Network/applicationGateways/httpListeners', name, 'listener-${site.name}-http')
      }
      redirectConfiguration: {
        id: resourceId(
          'Microsoft.Network/applicationGateways/redirectConfigurations',
          name,
          'redirect-https-${site.name}'
        )
      }
    }
  }
]

var routingRulesHttps = [
  for (site, i) in filter(sites, site => !contains(site, 'pathBased')): {
    name: 'rule-${site.name}-https'
    properties: {
      ruleType: 'Basic'
      priority: 200 + 200 * indexOf(sites, first(filter(sites, s => s.name == site.name)))
      httpListener: {
        id: resourceId('Microsoft.Network/applicationGateways/httpListeners', name, 'listener-${site.name}-https')
      }
      backendAddressPool: !contains(site, 'redirection')
        ? {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', name, 'pool-${site.name}')
          }
        : null
      backendHttpSettings: !contains(site, 'redirection')
        ? {
            id: resourceId(
              'Microsoft.Network/applicationGateways/backendHttpSettingsCollection',
              name,
              'settings-${site.name}'
            )
          }
        : null
      rewriteRuleSet: contains(site, 'rewriteRuleSet')
        ? {
            id: resourceId('Microsoft.Network/applicationGateways/rewriteRuleSets', name, 'rewrite-${site.name}')
          }
        : contains(site, 'deleteResponseHeaders') && site.deleteResponseHeaders
            ? {
                id: resourceId(
                  'Microsoft.Network/applicationGateways/rewriteRuleSets',
                  name,
                  'rewrite-delete-response-headers-01'
                )
              }
            : null
      redirectConfiguration: contains(site, 'redirection')
        ? {
            id: resourceId(
              'Microsoft.Network/applicationGateways/redirectConfigurations',
              name,
              'redirect-ext-${site.name}'
            )
          }
        : null
    }
  }
]

var routingRulesHttpsPathBased = [
  for (site, i) in filter(sites, site => contains(site, 'pathBased') && site.pathBased): {
    name: 'rule-${site.name}-https'
    properties: {
      ruleType: 'PathBasedRouting'
      priority: 200 + 200 * indexOf(sites, first(filter(sites, s => s.name == site.name)))
      httpListener: {
        id: resourceId('Microsoft.Network/applicationGateways/httpListeners', name, 'listener-${site.name}-https')
      }
      urlPathMap: {
        id: resourceId('Microsoft.Network/applicationGateways/urlPathMaps', name, 'map-${site.name}')
      }
    }
  }
]

var probesSites = [
  for site in filter(sites, site => contains(site, 'backendAddresses')): {
    name: 'probe-${site.name}'
    properties: {
      protocol: site.?backendSettingsProtocol ?? 'Https'
      path: site.probePath
      interval: 30
      timeout: 30
      unhealthyThreshold: 3
      pickHostNameFromBackendHttpSettings: site.pickHostNameFromBackendAddress
      host: site.pickHostNameFromBackendAddress ? null : site.backendAddresses[0].fqdn
      match: {}
    }
  }
]

var probesPaths = [
  for rule in pathRules: {
    name: 'probe-${rule.site}-${rule.name}'
    properties: {
      protocol: rule.?backendSettingsProtocol ?? 'Https'
      path: rule.probePath
      interval: 30
      timeout: 30
      unhealthyThreshold: 3
      pickHostNameFromBackendHttpSettings: rule.pickHostNameFromBackendAddress
      host: rule.pickHostNameFromBackendAddress ? null : rule.backendAddresses[0].fqdn
      match: {}
    }
  }
]

var pathRulesArray = [
  for (rule, i) in pathRules: {
    name: 'path-${rule.name}'
    site: rule.site
    properties: {
      paths: rule.paths
      backendAddressPool: {
        id: resourceId(
          'Microsoft.Network/applicationGateways/backendAddressPools',
          name,
          'pool-${rule.site}-${rule.name}'
        )
      }
      backendHttpSettings: {
        id: resourceId(
          'Microsoft.Network/applicationGateways/backendHttpSettingsCollection',
          name,
          'settings-${rule.site}-${rule.name}'
        )
      }
      rewriteRuleSet: contains(rule, 'rewriteRuleSet')
        ? {
            id: resourceId(
              'Microsoft.Network/applicationGateways/rewriteRuleSets',
              name,
              'rewrite-${rule.site}-${rule.name}'
            )
          }
        : null
      firewallPolicy: !contains(rule, 'waf')
        ? null
        : {
            id: resourceId(rg.name, 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies', 'waf-${replace(prefix, 'waf', rule.name)}-01') //pathWaf[i].outputs.resourceId
          }
    }
  }
]

var responseHeaders = [
  'X-Powered-By'
  'Server'
]

var responseHeaderConfigurations = [
  for responseHeader in responseHeaders: {
    headerName: responseHeader
  }
]

var rewriteRuleSetsNoResponseHeaders = [
  {
    name: 'rewrite-delete-response-headers-01'
    properties: {
      rewriteRules: [
        {
          ruleSequence: 1
          conditions: []
          name: 'delete-response-headers-01'
          actionSet: {
            responseHeaderConfigurations: responseHeaderConfigurations
          }
        }
      ]
    }
  }
]

var rewriteRuleSetsSites = [
  for site in filter(sites, site => contains(site, 'rewriteRuleSet') && !contains(site, 'deleteResponseHeaders')): {
    name: 'rewrite-${site.name}'
    properties: {
      rewriteRules: [
        {
          name: 'rule-${site.name}'
          actionSet: site.rewriteRuleSet.actionSet
        }
      ]
    }
  }
]

var rewriteRuleSetsPaths = [
  for rule in filter(pathRules, rule => contains(rule, 'rewriteRuleSet')): {
    name: 'rewrite-${rule.site}-${rule.name}'
    properties: {
      rewriteRules: [
        {
          name: 'rule-${rule.name}'
          actionSet: rule.rewriteRuleSet.actionSet
        }
      ]
    }
  }
]

var redirectsHttpToHttps = [
  for site in sites: {
    name: 'redirect-https-${site.name}'
    properties: {
      redirectType: 'Permanent'
      targetListener: {
        id: resourceId('Microsoft.Network/applicationGateways/httpListeners', name, 'listener-${site.name}-https')
      }
      includePath: true
      includeQueryString: true
      requestRoutingRules: [
        {
          id: resourceId('Microsoft.Network/applicationGateways/requestRoutingRules', name, 'rule-${site.name}-http')
        }
      ]
    }
  }
]

var redirectsHttpsToExternalUrl = [
  for site in filter(sites, site => contains(site, 'redirection')): {
    name: 'redirect-ext-${site.name}'
    properties: {
      redirectType: site.redirection.redirectType
      targetUrl: site.redirection.targetUrl
      includePath: site.redirection.includePath
      includeQueryString: site.redirection.includeQueryString
      requestRoutingRules: [
        {
          id: resourceId('Microsoft.Network/applicationGateways/requestRoutingRules', name, 'rule-${site.name}-https')
        }
      ]
    }
  }
]

resource kv 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: 'kv-${prefixCert}-01'
  scope: resourceGroup('rg-${prefixCert}-01')

  resource secret 'secrets' existing = [
    for sslCertificate in sslCertificates: {
      name: sslCertificate
    }
  ]
}

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${prefix}-01'
  location: location
  tags: tags
}

module wafDefault 'br/public:avm/res/network/application-gateway-web-application-firewall-policy:0.1.1' = {
  scope: rg
  name: 'waf-default'
  params: {
    name: 'waf-${replace(prefix, 'waf', 'default')}-01'
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

module waf 'br/public:avm/res/network/application-gateway-web-application-firewall-policy:0.1.1' = [
  for site in sites: if (contains(site, 'waf')) {
    scope: rg
    name: 'waf-${site.name}'
    params: {
      name: 'waf-${replace(prefix, 'waf', site.name)}-01'
      tags: rg.tags
      policySettings: {
        state: 'Enabled'
        mode: 'Prevention'
        maxRequestBodySizeInKb: site.waf.?maxRequestBodySizeInKb ?? 128
        fileUploadLimitInMb: site.waf.?fileUploadLimitInMb ?? 100
      }
      managedRules: {
        managedRuleSets: [
          {
            ruleSetType: 'OWASP'
            ruleSetVersion: ruleSetVersion
            ruleGroupOverrides: site.waf.ruleGroupOverrides
          }
        ]
        exclusions: site.waf.?exclusions ?? null
      }
      customRules: site.waf.customRules
    }
  }
]

module pathWaf 'br/public:avm/res/network/application-gateway-web-application-firewall-policy:0.1.1' = [
  for rule in pathRules: if (contains(rule, 'waf')) {
    scope: rg
    name: 'waf-${rule.name}'
    params: {
      name: 'waf-${replace(prefix, 'waf', rule.name)}-01'
      tags: rg.tags
      policySettings: {
        state: 'Enabled'
        mode: 'Prevention'
        maxRequestBodySizeInKb: rule.waf.?maxRequestBodySizeInKb ?? 128
        fileUploadLimitInMb: rule.waf.?fileUploadLimitInMb ?? 100
      }
      managedRules: {
        managedRuleSets: [
          {
            ruleSetType: 'OWASP'
            ruleSetVersion: ruleSetVersion
            ruleGroupOverrides: rule.waf.ruleGroupOverrides
          }
        ]
        exclusions: rule.waf.?exclusions ?? null
      }
      customRules: rule.waf.customRules
    }
  }
]

module id 'br:mcr.microsoft.com/bicep/avm/res/managed-identity/user-assigned-identity:0.4.0' = {
  scope: rg
  name: 'id-agw'
  params: {
    name: 'id-${name}'
    tags: rg.tags
  }
}

module pip 'br:mcr.microsoft.com/bicep/avm/res/network/public-ip-address:0.6.0' = {
  scope: rg
  name: 'pip-agw'
  params: {
    name: 'pip-${name}'
    tags: rg.tags
    publicIPAllocationMethod: 'Static'
    skuName: 'Standard'
    dnsSettings: {
      domainNameLabel: 'pip-${name}-${unique}'
      domainNameLabelScope: 'TenantReuse'
    }
    diagnosticSettings: !empty(logId)
    ? [
        {
          workspaceResourceId: logId
          logCategoriesAndGroups: [
            {
              enabled: true
              category: 'DDoSProtectionNotifications'
            }
            {
              enabled: true
              category: 'DDoSMitigationFlowLogs'
            }
            {
              enabled: true
              category: 'DDoSMitigationReports'
            }
          ]
        }
      ]
    : []
  }
}

module agw 'br:mcr.microsoft.com/bicep/avm/res/network/application-gateway:0.5.0' = {
  scope: rg
  name: 'agw'
  params: {
    name: name
    tags: rg.tags
    sku: 'WAF_v2'
    enableHttp2: true
    firewallPolicyResourceId: wafDefault.outputs.resourceId
    autoscaleMinCapacity: 0
    autoscaleMaxCapacity: 1
    sslPolicyType: 'Predefined'
    sslPolicyName: policyName
    sslCertificates: [
      for (sslCertificate, i) in sslCertificates: {
        name: sslCertificate
        properties: {
          keyVaultSecretId: kv::secret[i].properties.secretUri
        }
      }
    ]
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
            id: pip.outputs.resourceId
          }
        }
      }
      {
        name: snetName
        properties: {
          privateIPAddress: privateIPAddress
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: snetId
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
    httpListeners: concat(listenersHttp, listenersHttps)
    backendAddressPools: union(backendAddressPoolsSites, backendAddressPoolsPaths)
    probes: union(probesSites, probesPaths)
    backendHttpSettingsCollection: union(backendHttpSettingsCollectionSites, backendHttpSettingsCollectionPaths)
    redirectConfigurations: union(redirectsHttpToHttps, redirectsHttpsToExternalUrl)
    urlPathMaps: [
      for site in filter(sites, site => contains(site, 'pathBased') && site.pathBased): {
        name: 'map-${site.name}'
        properties: {
          defaultBackendHttpSettings: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/backendHttpSettingsCollection',
              name,
              'settings-${site.name}'
            )
          }
          defaultBackendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', name, 'pool-${site.name}')
          }
          pathRules: map(
            filter(pathRulesArray, rule => rule.site == site.name),
            rule => { name: rule.name, properties: rule.properties }
          )
        }
      }
    ]
    rewriteRuleSets: union(rewriteRuleSetsNoResponseHeaders, rewriteRuleSetsSites, rewriteRuleSetsPaths)
    requestRoutingRules: union(routingRulesHttp, routingRulesHttps, routingRulesHttpsPathBased)
    diagnosticSettings: !empty(logId)
      ? [
          {
            workspaceResourceId: logId
            logCategoriesAndGroups: [
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
        ]
      : []
  }
}


