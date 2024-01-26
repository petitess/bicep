targetScope = 'subscription'

param config object
param environment string
param timestamp int = dateTimeToEpoch(utcNow())
param location string = deployment().location

var prefixWaf = toLower('${config.product}-waf-${environment}-${config.location}')
var prefixSpoke = toLower('${config.product}-spoke-${environment}-${config.location}')
var prefixMonitor = toLower('${config.product}-monitor-${environment}-${config.location}')
var prefixCert = toLower('${config.product}-cert-${environment}-${config.location}')
var unique = take(subscription().subscriptionId, 3)
var snet = toObject(vnet.outputs.subnets, subnet => subnet.name)
var allowedSubnets = {
  dev: {
    monitor: '10.100.25.64/27'
    sales: '10.100.22.0/27'
    sven: '10.100.52.0/27'
    avd: '10.100.55.0/24'
  }
  stg: {
    monitor: '10.100.26.64/27'
    sales: '10.100.23.0/27'
    sven: '10.100.53.0/27'
    avd: '10.100.56.0/24'
  }
  prod: {
    monitor: '10.100.27.64/27'
    sales: '10.100.24.0/27'
    sven: '10.100.54.0/27'
    avd: '10.100.57.0/24'
  }
}

resource rgSpoke 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${prefixSpoke}-01'
  location: location
  tags: union(config.tags, {
      System: 'Vnet'
    })
}

resource rgMonitor 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${prefixMonitor}-01'
  location: location
  tags: union(config.tags, {
      System: 'Monitor'
    })
}

module log 'modules/log.bicep' = {
  scope: rgMonitor
  name: 'log_${timestamp}'
  params: {
    name: 'log-${prefixMonitor}-01'
    location: location
  }
}

resource rgWaf 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${prefixWaf}-01'
  location: location
  tags: union(config.tags, {
      System: 'Web Application Firewall'
    })
}

resource rgCert 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${prefixCert}-01'
  location: location
  tags: union(config.tags, {
      System: 'Certificate'
    })
}

module vnet 'modules/vnet.bicep' = {
  name: 'vnet_${timestamp}'
  scope: rgSpoke
  params: {
    prefix: prefixSpoke
    location: location
    addressPrefixes: config.vnet.addressPrefixes
    subnets: config.vnet.subnets
    allowedSubnets: allowedSubnets[environment]
  }
}

module agw 'modules/agw.bicep' = {
  name: 'agw_${timestamp}'
  scope: rgWaf
  params: {
    prefix: prefixWaf
    unique: unique
    location: location
    snetName: 'snet-agw'
    privateIPAddress: config.agw.privateIPAddress
    snetId: snet['snet-agw'].id
    sslCertificates: config.agw.sslCertificates
    sites: config.agw.sites
    pathRules: config.agw.pathRules
    logId: log.outputs.id
    prefixCert: prefixCert
  }
}

module rbacWaf 'modules/rbac.bicep' = {
  name: 'rbacAgw_${timestamp}'
  scope: rgWaf
  params: {
    principalId: agw.outputs.principalId
    roles: [
      'Key Vault Secrets User'
    ]
  }
}

resource id 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: 'id-agw-${prefixWaf}-01'
  scope: rgWaf
}

module kvCert 'modules/kv.bicep' = {
  scope: rgCert
  name: 'kvCert_${timestamp}'
  params: {
    name: 'kv-${prefixCert}-01'
    location: location
    defaultAction: 'Deny'
    enableRbac: false
    workspaceId: log.outputs.id
    virtualNetworkRules: [
      {
        id: snet['snet-agw'].id
      }
    ]
    accessPolicies: [
      {
        tenantId: tenant().tenantId
        objectId: '2d0abffa-b360-4f2f-9478-951498a43bd8' //Microsoft Azure App Service
        permissions: config.kvPermissions.appPermissions
      }
      {
        tenantId: tenant().tenantId
        objectId: id.properties.principalId
        permissions: config.kvPermissions.appPermissions
      }
    ]
  }
}
