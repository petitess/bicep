targetScope = 'subscription'

param param object
var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var env = toLower(param.tags.Environment)

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: param.location
  tags: param.tags
  name: 'rg-app-${env}-01'
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

module kv 'kv.bicep' = {
  scope: rg
  name: 'module-${affix}-kv'
  params: {
    location: param.location
    name: 'kv-comp-${affix}-01'
  }
}

module bus 'bus.bicep' = {
  scope: rg
  name: 'module-${affix}-bus'
  params: {
    location: param.location
    env: env
  }
}

module sql 'sql.bicep' = {
  scope: rg
  name: 'module-${affix}-sql'
  params: {
    location: param.location
    env: env
  }
}

module appitglueint 'appitglueint.bicep' = {
  scope: rg
  name: 'module-${affix}-appint'
  params: {
    appiconstring: appin.outputs.ConnectionString
    KeyVaultUrl: kv.outputs.kvUrl
    location: rg.location
    env: env
  }
}

