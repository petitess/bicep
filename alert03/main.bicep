targetScope = 'subscription'

param param object
var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var env = toLower(param.tags.Environment)

resource rginfra 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: param.location
  tags: param.tags
  name: 'rg-${affix}-sc-01'
}

module log 'log.bicep' = {
  name: 'module-${env}-log'
  scope: rginfra
  params: {
    name: 'log-${affix}-01'
    location: param.location
    sku: param.log.sku
    retentionInDays: param.log.retention
    solutions: [] //param.log.solutions
    events: param.log.events
  }
}

module ag 'ag.bicep' = {
  scope: rginfra
  name: 'module-${affix}-ag01'
  params: {
    name: replace('AG${env}01', '-', '')
    tags: {
    }
  }
}

module logalert 'alert.bicep' = {
  name: 'module-${affix}-alert01'
  scope: rginfra
  params: {
    location: param.location
    actionGroup: ag.outputs.actiongrpid
  }
}
