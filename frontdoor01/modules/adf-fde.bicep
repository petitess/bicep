param tags object = resourceGroup().tags
param location string
param appName string
param plServiceId string
param customRules array
param ruleGroupOverrides array = []
param customDomain string
param DnsZoneId string
param env string
param queryStringCachingBehavior string
param isCompressionEnabled bool
param certificateName string
param rules array
param origins array
param probePath string = '/'
param probeProtocol 'Http' | 'Https' = 'Https'
param forwardingProtocol 'HttpsOnly' | 'HttpOnly' | 'MatchRequest' = 'HttpsOnly'

var sku = 'Standard_AzureFrontDoor'

resource afd 'Microsoft.Cdn/profiles@2024-02-01' existing = {
  name: 'afd-${env}-01'
  scope: resourceGroup()
}

resource fde 'Microsoft.Cdn/profiles/afdEndpoints@2024-02-01' = {
  parent: afd
  name: 'fde-${appName}'
  location: 'Global'
  tags: tags
  properties: {
    enabledState: 'Enabled'
  }
}

resource ogrp 'Microsoft.Cdn/profiles/originGroups@2024-02-01' = {
  parent: afd
  name: 'grp-${appName}'
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }
    healthProbeSettings: {
      probePath: probePath
      probeRequestType: 'GET'
      probeProtocol: probeProtocol
      probeIntervalInSeconds: 100
    }
    sessionAffinityState: 'Enabled'
  }
}

resource orgin 'Microsoft.Cdn/profiles/originGroups/origins@2024-02-01' = [
  for (origin, i) in origins: {
    name: split(origin.appFqdn, '.')[0]
    parent: ogrp
    properties: {
      hostName: origin.appFqdn
      httpPort: 80
      httpsPort: 443
      priority: 1
      weight: 1000
      enabledState: 'Enabled'
      enforceCertificateNameCheck: true
      sharedPrivateLinkResource: contains(origin, 'appGroupId') && !empty(origin.appGroupId)
        ? {
            privateLink: {
              id: plServiceId
            }
            groupId: origin.appGroupId
            privateLinkLocation: location
            requestMessage: 'PEP for ${appName}'
          }
        : null
    }
  }
]

resource route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2024-02-01' = {
  parent: fde
  name: 'rt-${appName}'
  dependsOn: [
    orgin
  ]
  properties: {
    customDomains: !empty(customDomain)
      ? [
          {
            id: customdomain.id
          }
        ]
      : []
    originGroup: {
      id: ogrp.id
    }
    ruleSets: !empty(rules)
      ? [
          {
            id: ruleset.id
          }
        ]
      : []
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: forwardingProtocol
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
    enabledState: 'Enabled'
    cacheConfiguration: false
      ? {
          queryStringCachingBehavior: queryStringCachingBehavior
          compressionSettings: {
            isCompressionEnabled: isCompressionEnabled
            contentTypesToCompress: [
              'application/eot'
              'application/font'
              'application/font-sfnt'
              'application/javascript'
              'application/json'
              'application/opentype'
              'application/otf'
              'application/pkcs7-mime'
              'application/truetype'
              'application/ttf'
              'application/vnd.ms-fontobject'
              'application/xhtml+xml'
              'application/xml'
              'application/xml+rss'
              'application/x-font-opentype'
              'application/x-font-truetype'
              'application/x-font-ttf'
              'application/x-httpd-cgi'
              'application/x-javascript'
              'application/x-mpegurl'
              'application/x-opentype'
              'application/x-otf'
              'application/x-perl'
              'application/x-ttf'
              'font/eot'
              'font/ttf'
              'font/otf'
              'font/opentype'
              'image/svg+xml'
              'text/css'
              'text/csv'
              'text/html'
              'text/javascript'
              'text/js'
              'text/plain'
              'text/richtext'
              'text/tab-separated-values'
              'text/xml'
              'text/x-script'
              'text/x-component'
              'text/x-java-source'
            ]
          }
        }
      : {}
  }
}

resource securitypolicie 'Microsoft.Cdn/profiles/securityPolicies@2024-02-01' = {
  parent: afd
  name: 'sec-${appName}'
  properties: {
    parameters: {
      wafPolicy: {
        id: fdfp.id
      }
      associations: [
        {
          domains: [
            {
              id: fde.id
            }
          ]
          patternsToMatch: [
            '/*'
          ]
        }
      ]
      type: 'WebApplicationFirewall'
    }
  }
}

resource fdfp 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2024-02-01' = {
  name: replace('WAF${appName}', '-', '')
  location: 'Global'
  tags: tags
  sku: {
    name: sku
  }
  properties: {
    policySettings: {
      enabledState: 'Enabled'
      mode: 'Detection'
      requestBodyCheck: 'Enabled'
    }
    customRules: {
      rules: customRules
    }
    managedRules: sku == 'Premium_AzureFrontDoor'
      ? {
          managedRuleSets: [
            {
              ruleSetType: 'Microsoft_DefaultRuleSet'
              ruleSetVersion: '2.1'
              ruleSetAction: 'Block'
              ruleGroupOverrides: ruleGroupOverrides
              exclusions: []
            }
          ]
        }
      : {}
  }
}

resource certificateSecret 'Microsoft.Cdn/profiles/secrets@2024-02-01' existing = if (!empty(certificateName)) {
  name: !empty(certificateName) ? certificateName : 'ssg-se'
  parent: afd
}

resource customdomain 'Microsoft.Cdn/profiles/customDomains@2024-02-01' = if (!empty(customDomain)) {
  parent: afd
  name: (!empty(customDomain)) ? replace(customDomain, '.', '-') : 'customDomains'
  properties: {
    hostName: customDomain
    tlsSettings: {
      certificateType: !empty(certificateName) ? 'CustomerCertificate' : 'ManagedCertificate'
      secret: !empty(certificateName)
        ? {
            id: certificateSecret.id
          }
        : null
      minimumTlsVersion: 'TLS12'
    }
    azureDnsZone: {
      id: DnsZoneId
    }
  }
}

resource ruleset 'Microsoft.Cdn/profiles/ruleSets@2024-02-01' = if (!empty(rules)) {
  parent: afd
  name: 'ruleset${replace(appName, '-', '')}'
}

resource rule 'Microsoft.Cdn/profiles/ruleSets/rules@2024-02-01' = [
  for r in rules: if (!empty(rules)) {
    name: r.name
    parent: ruleset
    properties: r.properties
  }
]

output token string = !empty(customDomain) && empty(certificateName)
  ? customdomain.properties.validationProperties.validationToken
  : ''
output endpointUrl string = fde.properties.hostName
