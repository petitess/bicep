targetScope = 'subscription'

param location string
param tags object

param webtests array

var affix = toLower('${tags.Application}-${tags.Environment}')
func name(prefix string, instance string) string => '${prefix}-${affix}-${instance}'

resource rgMgmt 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: name('rg-management', '02')
  location: location
  tags: tags
}

module log 'modules/log.bicep' = {
  name: 'log'
  scope: rgMgmt
  params: {
    name: name('log', '01')
    location: location
    sku: 'PerGB2018'
    retentionInDays: 30
    solutions: [
      'VMInsights'
      'Security'
      'ServiceMap'
      'ChangeTracking'
    ]
    events: [
      'System'
      'Application'
    ]
  }
}

module ag 'modules/ag.bicep' = {
  scope: rgMgmt
  name: 'action-groups'
  params: {
    automationAccountId: aa.outputs.id
    webhookResourceId: aa.outputs.webhookId
    webhookResourceUrl: aa.outputs.webhookUrl
  }
}

module rbacAg 'modules/rbac.bicep' = {
  scope: rgMgmt
  name: 'rbac-ag'
  params: {
    principalId: ag.outputs.actionGroupRestartGtmPrinciplaId
    roles: [
      'Contributor'
    ]
  }
}

module appInsight 'modules/appi.bicep' = {
  scope: rgMgmt
  name: 'appi'
  params: {
    name: name('appi', '01')
    location: location
    WorkspaceResourceId: log.outputs.id
    webtests: webtests
    actionGroupId: ag.outputs.actionGroupP3Bas
    actionGroupRestartGtm: ag.outputs.actionGroupRestartGtm
  }
}

module aa 'modules/aa.bicep' = {
  scope: rgMgmt
  name: 'aa'
  params: {
    location: location
    name: name('aa', '01')
    privateEndpoints: {}
  }
}

module rbacAa 'modules/rbac.bicep' = {
  scope: rgMgmt
  name: 'rbac-aa'
  params: {
    principalId: aa.outputs.principalId
    roles: [
      'Contributor'
    ]
  }
}
