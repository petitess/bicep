targetScope = 'tenant' 

param param object

var affix = '${param.company.affix}-${param.environment.affix}'
var env = param.environment.affix
var subid = param.subscription.id 

resource mg 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: 'mg-${affix}-01'
}

resource sub 'Microsoft.Management/managementGroups/subscriptions@2021-04-01' = {
  parent: mg
  name: subid
}

module policy 'policy.bicep' = {
  scope: managementGroup(mg.name)
  name: 'module-${env}-policy'
  params: {
    managementGroupName: mg.name
  }
}
