targetScope = 'subscription'

param param object

var prefix = toLower('${param.tags.Application}-${param.tags.Environment}')
var env = toLower(param.tags.Environment)

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  location: param.location
  tags: param.tags
  name: 'rg-${prefix}-01'
}

module vnet 'vnet.bicep' = {
  scope: rg
  name: 'module-vnet-${env}'
  params: {
    addressPrefixes: param.vnet.addressPrefixes
    location: param.location
    prefix: prefix
    subnets: param.vnet.subnets
  }
}

module ag 'ag.bicep' = {
  scope: rg
  name: 'module-ag-${env}'
  params: {
    name: 'ag-${env}-01'
    tags: {
    }
  }
}

module log 'log.bicep' = {
  name: 'module-log-${env}'
  scope: rg
  params: {
    name: 'log-${prefix}-01'
    location: param.location
    sku: param.log.sku
    retentionInDays: param.log.retention
    solutions: param.log.solutions
    events: param.log.events
  }
}

module pdnsz 'pdnsz.bicep' = [for dns in param.pdnsz: {
  scope: rg
  name: 'module-${dns}'
  params: {
    name: dns
    vnetId: vnet.outputs.id
  }
}]

module azuremonitor 'azuremonitor.bicep' = {
  scope: rg
  name: 'module-monitor-${env}'
  params: {
    location: param.location
    logId: log.outputs.id
    appiId: appi.outputs.appiId
    snetId: vnet.outputs.snet['snet-pep'].id
  }
}

module appi 'appinsight.bicep' = {
  scope: rg
  name: 'module-appi-${env}'
  params: {
    location: param.location
    name: 'appi-${prefix}-01'
    webtests: param.webtests
    WorkspaceResourceId: log.outputs.id
    actionGroupId: ag.outputs.actiongrpid
  }
}
