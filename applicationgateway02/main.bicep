targetScope = 'subscription'

param config object
param environment string
param timestamp string = utcNow('ddMMyyyy')
param location string = deployment().location

var prefix = toLower('${config.product}-spoke-${environment}-${config.location}')
var prefixWaf = toLower('${config.product}-waf-${environment}-${config.location}')
var unique = take(subscription().subscriptionId, 3)
var certInstalled = false
var rbacAssigned = false

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

resource rgWaf 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${prefixWaf}-01'
  location: location
  tags: union(config.tags, {
      System: 'Web Application Firewall'
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

module agw 'agw.bicep' = if(certInstalled) {
  name: 'agw_${timestamp}'
  scope: rgWaf
  params: {
    prefix: prefixWaf
    unique: unique
    location: location
    snetName: 'snet-agw'
    snetId: vnet.outputs.snet['snet-agw'].id
    sslCertificates: config.agw.sslCertificates
    sites: config.agw.sites
    rbacAssigned: rbacAssigned
  }
}

module rbacWaf 'rbac.bicep' = {
  name: 'rbacAgw_${timestamp}'
  scope: rgWaf
  params: {
    principalId: agw.outputs.principalId
    roles: [
      'Key Vault Secrets User'
    ]
  }
}

module kvWaf 'kv.bicep' = {
  scope: rgWaf
  name: 'kvWaf_${timestamp}'
  params: {
    name: 'kv-${prefixWaf}-01'
    location: location
    defaultAction: 'Deny'
    virtualNetworkRules: [
      {
        id: vnet.outputs.snet['snet-agw'].id
      }
    ]
  }
}

output vnet string = vnet.name
output time string = timestamp
output loc string = location
