targetScope = 'subscription'

param location string = deployment().location
param tags object = {
  Application: 'GTM'
  Environment: 'Dev'
}
param webtests array = []
var affix = toLower('${tags.Application}-${tags.Environment}')
var env = toLower(tags.Environment)

resource rgapp 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  location: location
  tags: tags
  name: 'rg-app-gtm-${env}-01'
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
    location: location
    retentionInDays: 30
    solutions:[]
    events: []
  }
}

module appin 'appinsight.bicep' = {
  scope: rgapp
  name: 'module-${env}-appinsight'
  params: {
    name: 'appi-${affix}-01'
    location: location
    WorkspaceResourceId: log.outputs.id
    webtests: webtests
  }
}
