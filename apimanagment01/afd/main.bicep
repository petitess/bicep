targetScope = 'subscription'

param config object
param environment string
param timestamp int = dateTimeToEpoch(utcNow())
param location string = deployment().location

var prefixMonitor = toLower('${config.product}-monitor-${environment}-${config.location}')
var prefixAfd = toLower('${config.product}-fdfp-${environment}-${config.location}')
var prefixCert = toLower('${config.product}-cert-${environment}-${config.location}')
var prefixSpoke = toLower('${config.product}-spoke-${environment}-${config.location}')
var platform = {
  subId: '9e9cc591-ecad-4d1c-8e2b-04523f31826d'
  dnsRg: 'rg-platform-dns-prod-we-01'
}

resource rgMonitor 'Microsoft.Resources/resourceGroups@2024-11-01' existing = {
  name: 'rg-${prefixMonitor}-01'
}

resource log 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: 'log-${prefixMonitor}-01'
  scope: rgMonitor
}

resource rgAfd 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: 'rg-${prefixAfd}-01'
  location: location
  tags: union(config.tags, {
    System: 'Azure Front Door'
  })
}

module afd 'modules/afd.bicep' = {
  scope: rgAfd
  name: 'afd_${timestamp}'
  params: {
    name: 'afd-${prefixAfd}-01'
    logId: log.id
    prefixCert: prefixCert
    prefixSpoke: prefixSpoke
    sslCertificates: config.sslCertificates
  }
}

module fdendpoint 'modules/fde.bicep' = [
  for fde in config.frontdoorEndpoints: {
    scope: rgAfd
    name: fde.fdeName
    params: {
      location: location
      prefixAfd: prefixAfd
      appName: fde.fdeName
      appFqdn: fde.appFqdn
      plServiceId: resourceId(
        contains(fde, 'appGroupId') && !empty(fde.appGroupId) ? fde.subscriptionId : subscription().subscriptionId,
        contains(fde, 'appGroupId') && !empty(fde.appGroupId) ? fde.appRg : rgAfd.name,
        contains(fde, 'appGroupId') && !empty(fde.appGroupId) ? fde.resourceType : rgAfd.type,
        contains(fde, 'appGroupId') && !empty(fde.appGroupId) ? fde.appName : rgAfd.name
      )
      appGroupId: fde.?appGroupId ?? ''
      customDomain: fde.?customDomain ?? ''
      domainDeploymentName: fde.?domainDeploymentName ?? ''
      DnsZoneId: resourceId(platform.subId, platform.dnsRg, 'Microsoft.Network/dnszones', fde.DnsZoneName)
      customRules: fde.customRules
      ruleGroupOverrides: fde.ruleGroupOverrides
      exclusions: fde.?exclusions ?? []
      isCompressionEnabled: fde.isCompressionEnabled
      queryStringCachingBehavior: fde.queryStringCachingBehavior
      certificateName: fde.?certificateName ?? ''
      rules: fde.?rules ?? []
      disableHealthProbe: fde.?disableHealthProbe ?? false
      disableCache: fde.?disableCache ?? false
    }
    dependsOn: [
      afd
    ]
  }
]

module publicDns 'modules/dns.bicep' = [
  for (fde, i) in config.frontdoorEndpoints: if (!contains(fde, 'DnsZoneName') || !empty(fde.DnsZoneName)) {
    scope: resourceGroup(platform.subId, platform.dnsRg)
    name: 'dns-${fde.fdeName}'
    params: {
      name: fde.DnsZoneName
      deployCNAME: fde.deployCNAME
      Cname: fde.deployCNAME ? replace(fde.customDomain, '.${fde.DnsZoneName}', '') : 'x'
      CnameValue: fdendpoint[i].outputs.endpointUrl
      TXTname: '_dnsauth.${replace(fde.customDomain, '.${fde.DnsZoneName}', '')}'
      TXTValue: fdendpoint[i].outputs.token
    }
  }
]
