param tags object = resourceGroup().tags
param location string
param appName string
param appFqdn string
param plServiceId string
param appGroupId 'blob' | 'web' | 'sites' | ''
param customRules array
param ruleGroupOverrides array
param customDomain string
param DnsZoneId string
param prefixAfd string

resource afd 'Microsoft.Cdn/profiles@2023-05-01' existing = {
  name: 'afd-${prefixAfd}-01'
  scope: resourceGroup()
}

resource fde 'Microsoft.Cdn/profiles/afdEndpoints@2023-05-01' = {
  parent: afd
  name: 'fde-${appName}'
  location: 'Global'
  tags: tags
  properties: {
    enabledState: 'Enabled'
  }
}

resource ogrp 'Microsoft.Cdn/profiles/originGroups@2023-05-01' = {
  parent: afd
  name: 'grp-${appName}'
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'HEAD'
      probeProtocol: 'Https'
      probeIntervalInSeconds: 100
    }
    sessionAffinityState: 'Disabled'
  }
}

resource orgin 'Microsoft.Cdn/profiles/originGroups/origins@2023-05-01' = {
  name: 'orgin'
  parent: ogrp
  properties: {
    hostName: appFqdn
    httpPort: 80
    httpsPort: 443
    originHostHeader: appFqdn
    priority: 1
    weight: 1000
    enabledState: 'Enabled'
    enforceCertificateNameCheck: true
    sharedPrivateLinkResource: !empty(appGroupId) ? {
      privateLink: {
        id: plServiceId
      }
      groupId: appGroupId
      privateLinkLocation: location
      requestMessage: 'PEP for ${appName}'
    } : null
  }
}

resource route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2023-05-01' = {
  parent: fde
  name: 'rt-${appName}'
  dependsOn: [
    orgin
  ]
  properties: {
    customDomains: !empty(customDomain) ? [
      {
        id: customdomain.id
      }
    ] : []
    originGroup: {
      id: ogrp.id
    }
    ruleSets: []
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
    enabledState: 'Enabled'
  }
}

resource securitypolicie 'Microsoft.Cdn/profiles/securityPolicies@2023-05-01' = {
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

resource fdfp 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2022-05-01' = {
  name: replace('WAF${appName}', '-', '')
  location: 'Global'
  tags: tags
  sku: {
    name: 'Premium_AzureFrontDoor'
  }
  properties: {
    policySettings: {
      enabledState: 'Enabled'
      mode: 'Prevention'
      requestBodyCheck: 'Enabled'
    }
    customRules: {
      rules: customRules
    }
    managedRules: {
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
  }
}

resource customdomain 'Microsoft.Cdn/profiles/customDomains@2023-05-01' = if (!empty(customDomain)) {
  parent: afd
  name: (!empty(customDomain)) ? replace(customDomain, '.', '-') : 'customDomains'
  properties: {
    hostName: customDomain
    tlsSettings: {
      certificateType: 'ManagedCertificate'
      minimumTlsVersion: 'TLS12'
    }
    azureDnsZone: {
      id: DnsZoneId
    }
  }
}
