targetScope = 'subscription'

param param object
var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var env = toLower(param.tags.Environment)

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: param.location
  tags: param.tags
  name: 'rg-${affix}-01'
}

module log 'log.bicep' = {
  name: 'module-${env}-log'
  scope: rg
  params: {
    name: 'log-${affix}-01'
    location: param.location
    sku: param.log.sku
    retentionInDays: param.log.retention
    solutions:[]// param.log.solutions
    events: param.log.events
  }
}

module appin 'appinsight.bicep' = {
  scope: rg
  name: 'module-${env}-appinsight'
  params: {
    name: 'appi-${affix}-01'
    location: param.location
    WorkspaceResourceId: log.outputs.id
    webtests: param.webtests
  }
}
