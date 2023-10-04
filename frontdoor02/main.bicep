targetScope = 'subscription'

param config object
param environment string
param timestamp int = dateTimeToEpoch(utcNow())
param location string = deployment().location

var prefixAfd = toLower('${config.product}-fdfp-${environment}-${config.location}')

resource rgAfd 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${prefixAfd}-01'
  location: location
  tags: union(config.tags, {
      System: 'Azure Front Door'
    })
}

module afd 'afd.bicep' = {
  scope: rgAfd
  name: 'afd_${timestamp}'
  params: {
    name: 'afd-${prefixAfd}-01'
  }
}

module fde 'fde.bicep' = [for fde in config.frontdoorEndpoints: {
  scope: rgAfd
  name: 'fde-${fde.appName}'
  dependsOn: [ afd ]
  params: {
    location: location
    prefixAfd: prefixAfd
    appName: fde.appName
    appFqdn: fde.appFqdn
    plServiceId: resourceId(subscription().subscriptionId, fde.appRg, fde.resourceType, fde.appName)
    appGroupId: fde.appGroupId
    customDomain: fde.customDomain
    DnsZoneId: resourceId(subscription().subscriptionId, 'rg-publicdns', 'Microsoft.Network/dnszones', fde.DnsZoneName)
    customRules: fde.customRules
    ruleGroupOverrides: fde.ruleGroupOverrides
  }
}]
