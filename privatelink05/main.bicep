targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var env = toLower(param.tags.Environment)

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' ={
  location: param.location
  tags: param.tags
  name: 'rg-${affix}-01'
}

resource rgMonitor 'Microsoft.Resources/resourceGroups@2022-09-01' ={
  location: param.location
  tags: param.tags
  name: 'rg-monitor-${env}-01'
}

module vnet 'vnet.bicep' = {
  scope: rg
  name: 'module-vnet'
  params: {
    addressPrefixes: param.vnet.addressPrefixes
    affix: affix
    location: param.location
    subnets: param.vnet.subnets
  }
}

module log 'log.bicep' = {
  scope: rgMonitor
  name: 'module-log'
  params: {
    name: 'log-${env}-01'
    location: param.location
  }
}

module appi 'appi.bicep' = {
  scope: rgMonitor
  name: 'module-appi'
  params: {
    location: param.location
    name: 'appi-${env}-01'
    WorkspaceResourceId: log.outputs.id
  }
}

module monitor 'azuremonitor.bicep' = {
  scope: rgMonitor
  name: 'module-azure-monitor'
  params: {
    appiId: appi.outputs.id
    location: param.location
    logId: log.outputs.id
    snetId: vnet.outputs.snet['snet-pep'].id
    vnetId: vnet.outputs.id
  }
}
