targetScope = 'tenant' 

param param object

var affix = '${param.company.affix}-${param.environment.affix}'
var env = param.environment.affix
var subid = param.subscription.id 
var location = param.location.name
var tags = {
  Company: param.company.name
  Environment: param.environment.name
}

resource mg 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: 'mg-${affix}-01'
}

resource sub 'Microsoft.Management/managementGroups/subscriptions@2021-04-01' = {
  parent: mg
  name: subid
}

module tag 'tag.bicep' = {
  scope: subscription(subid)
  name: 'module-${affix}-tag'
  params: {
    tags: tags
  }
}

module policy 'policy.bicep' = {
  scope: managementGroup(mg.name)
  name: 'module-${env}-policy'
  params: {
    managementGroupName: mg.name
    location: location
    policyExclusions: param.policyExclusions
  }
}

module rbac 'rbac.bicep' = {
  name: 'module-${env}-rbac'
  scope: subscription(subid)
  params: {
    roleAssignments: param.roleAssignments
  }
}
