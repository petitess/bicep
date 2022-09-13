targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var location = param.location

resource rginfra 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-infra-${affix}-01'
  location: location
  tags: param.tags
}

module ag 'ag.bicep' = {
  scope: rginfra
  name: 'module-${affix}-ag01'
  params: {
    name: replace('AG${affix}01', '-', '')
    tags: {
    }
  }
}

module alert 'alert.bicep' = {
  scope: rginfra
  name: 'module-${affix}-alert01'
  params: {
    tags: param.tags
    actionGroupId: ag.outputs.actiongrpid
  }
}

