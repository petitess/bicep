targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var env = toLower(param.tags.Environment)

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${affix}-sc-01'
  location: param.location
  tags: param.tags
}

module policy 'policy.bicep' = {
  scope: subscription()
  name: 'module-${env}-policy'
  params: {
    location: param.location
    policyExclusions: []
  }
}
