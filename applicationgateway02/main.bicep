targetScope = 'subscription'

param config object
param environment string = 'dev'
param timestamp string = utcNow('ddMMyyyy')
param location string = deployment().location

var prefix = toLower('${config.product}-spoke-${environment}-${config.location}')

resource tags 'Microsoft.Resources/tags@2022-09-01' = {
  name: 'default'
  properties: {
    tags: config.tags
  }
}

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${prefix}-01'
  location: location
  tags: union(config.tags, {
      System: 'Spoke'
    })
}

module vnet 'vnet.bicep' = {
  name: 'vnet_${timestamp}'
  scope: rg
  params: {
    prefix: prefix
    location: location
    addressPrefixes: config.vnet.addressPrefixes
    dnsServers: []
    subnets: config.vnet.subnets
  }
}

module waf 'waf.bicep' = if (contains(config, 'waf')) {
  scope: rg
  name: 'waf_${timestamp}'
  params: {
    location: location
    name: 'waf-${prefix}-01'
    ruleGroupOverrides: config.waf.ruleGroupOverrides
    customRules: config.waf.customRules
  }
}

module agw 'agw.bicep' = {
  scope: rg
  name: 'module-agw-prod'
  params: {
    prefix: prefix
    name: 'agw-${prefix}-01'
    location: location
    wafId: waf.outputs.id
    snetId: vnet.outputs.snetId['snet-agw']
    webApplicationFirewallConfiguration: config.webApplicationFirewallConfiguration
    sites: config.agw.sites
  }
}

output vnet string = vnet.name
output time string = timestamp
output loc string = location
