targetScope = 'tenant'

param config object
param environment string = 'prod'
param timestamp string = utcNow('yyyymmdd')
param location string = deployment().location

var prefix = toLower('${config.product}-${environment}-${config.location}')
var platformSubscription = {
  name: 'Azure subscription 1'
  id: 'xxxxx-e3df-4ea1-b956-xxxxx'
}

var GroupRoles = [
  {
    GrpName: 'grp-rbac-sub-access-dev-01-contributor'
    ObjectId: 'xxx-a940-455c-803b-xxxx'
    SubId: platformSubscription.id
  }
  {
    GrpName: 'grp-rbac-sub-access-dev-01-owner'
    ObjectId: 'xxx-b424-4226-8009-xxxx'
    SubId: platformSubscription.id
  }
  {
    GrpName: 'grp-rbac-sub-access-dev-01-reader'
    ObjectId: 'xxxx-53d5-4841-8f80-xxx'
    SubId: platformSubscription.id
  }
]

module rgPlatform 'rg.bicep' = {
  scope: subscription(platformSubscription.id)
  name: 'sek_${config.product}_rg_${timestamp}'
  params: {
    location: location
    prefix: prefix
  }
}

module script 'script.bicep' = {
  scope: resourceGroup(platformSubscription.id, 'rg-${prefix}-01')
  name: 'sek_${config.product}_script_${timestamp}'
  dependsOn: [ rgPlatform ]
  params: {
    location: location
    prefix: prefix
    groupPrefix: config.groupPrefix
    tags: config.tags
  }
}

module rbacMgContributor 'rbac.bicep' = [for (role, i) in GroupRoles: if(contains(role.GrpName, 'contributor')) {
  name: 'rbac_c_${role.GrpName}'
  scope: subscription(role.SubId)
  params: {
    principalId: role.ObjectId
    roles: [
      'Contributor'
    ]
  }
}]

module rbacMgOwner 'rbac.bicep' = [for (role, i) in GroupRoles: if(contains(role.GrpName, 'owner')) {
  name: 'rbac_o_${role.GrpName}'
  scope: subscription(role.SubId)
  params: {
    principalId: role.ObjectId
    roles: [
      'Owner'
    ]
  }
}]

module rbacMgReader 'rbac.bicep' = [for (role, i) in GroupRoles: if(contains(role.GrpName, 'reader')) {
  name: 'rbac_r_${role.GrpName}'
  scope: subscription(role.SubId)
  params: {
    principalId: role.ObjectId
    roles: [
      'Reader'
    ]
  }
}]




