targetScope = 'subscription'

param param object
var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var env = toLower(param.tags.Environment)

resource rgapp 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: param.location
  tags: param.tags
  name: 'rg-app-${env}-sc-01'
}

module appgtm 'appgtm.bicep' = {
  scope: rgapp
  name: 'module-${affix}-appgtm'
  params: {
    affix: env
    location: rgapp.location
  }
}

module log 'log.bicep' = {
  name: 'module-${env}-log'
  scope: rgapp
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
  scope: rgapp
  name: 'module-${env}-appinsight'
  params: {
    name: 'appi-${affix}-01'
    location: param.location
    WorkspaceResourceId: log.outputs.id
    webtests: param.webtests
  }
}
