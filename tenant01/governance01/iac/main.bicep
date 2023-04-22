targetScope = 'tenant'

param config object
param environment string
param timestamp int
param location string = deployment().location

var prefixCompany = 'comp'
var prefix = toLower('${config.product}-${environment}-${config.location}')
var platformSubscription = {
  name: 'sub-platform-prod-01'
  id: 'xxx-1a10-483e-95aa-xxx'
}

resource mgPlatform 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: 'mg-platform-01'
}

resource mgLandingzones 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: 'mg-landingzones-01'
}

module rgPlatform 'modules/rg.bicep' = {
  scope: subscription(platformSubscription.id)
  name: '${prefixCompany}_${config.product}_rg_${timestamp}'
  params: {
    location: location
    prefix: prefix
    tags: config.tags
  }
}

module script 'modules/script.bicep' = {
  scope: resourceGroup(platformSubscription.id, 'rg-${prefix}-01')
  name: '${prefixCompany}_${config.product}_script_${timestamp}'
  params: {
    location: location
    prefix: prefix
    tags: config.tags
    groupPrefix: config.groupPrefix
  }
}

module rbacContributor 'modules/rbacSub.bicep' = [for role in config.groupRoles: if (contains(role.groupName, 'contributor')) {
  name: 'rbac_c_${role.groupName}'
  scope: subscription(role.SubId)
  params: {
    principalId: role.ObjectId
    roles: [
      'Contributor'
    ]
  }
}]

module rbacOwner 'modules/rbacSub.bicep' = [for role in config.groupRoles: if (contains(role.groupName, 'owner')) {
  name: 'rbac_o_${role.groupName}'
  scope: subscription(role.SubId)
  params: {
    principalId: role.ObjectId
    roles: [
      'Owner'
    ]
  }
}]

module rbacReader 'modules/rbacSub.bicep' = [for role in config.groupRoles: if (contains(role.groupName, 'reader')) {
  name: 'rbac_r_${role.groupName}'
  scope: subscription(role.SubId)
  params: {
    principalId: role.ObjectId
    roles: [
      'Reader'
    ]
  }
}]

module rbacHub 'modules/rbacRg.bicep' = {
  name: 'rbac_${timestamp}'
  scope: resourceGroup(platformSubscription.id, 'rg-platform-hub-prod-we-01')
  params: {
    principalId: config.principals['sp-landingzones-01']
    roles: [ 'Network Contributor' ]
  }
}

module rbacDns 'modules/rbacRg.bicep' = [for (principal, i) in items(config.principals): {
  name: 'rbacDns${i}_${timestamp}'
  scope: resourceGroup(platformSubscription.id, 'rg-platform-dns-prod-we-01')
  params: {
    principalId: principal.value
    roles: [
      'Network Contributor'
    ]
  }
}]

module policyPlatform 'modules/policy.bicep' = {
  scope: mgPlatform
  name: '${prefixCompany}_${config.product}_policy_platform_${timestamp}'
  params: {
    location: location
  }
}

module policyLandingzone 'modules/policy.bicep' = {
  scope: mgLandingzones
  name: '${prefixCompany}_${config.product}_policy_landingzone_${timestamp}'
  params: {
    location: location
  }
}
