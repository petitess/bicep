targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var env = toLower(param.tags.Environment)

resource rginfra 'Microsoft.Resources/resourceGroups@2022-09-01' ={
  location: param.location
  tags: param.tags
  name: 'rg-${affix}-01'
}

module vnet 'vnet.bicep' = {
  scope: rginfra
  name: 'module-${affix}-vnet'
  params: {
    addressPrefixes: param.vnet.addressPrefixes
    dnsServers: param.vnet.dnsServers
    location: param.location
    name: 'vnet-${affix}-01'
    natGateway: param.vnet.natGateway
    peerings: param.vnet.peerings
    subnets: param.vnet.subnets 
  }
}

module bas 'bas.bicep' = if(false) {
  scope: rginfra
  name: 'module-${affix}-bas'
  params: {
    location: param.location
    name: 'bas-${vnet.outputs.name}'
    vnetId: vnet.outputs.id
    subnet: vnet.outputs.snet.AzureBastionSubnet.id

  }
}

resource rgVm 'Microsoft.Resources/resourceGroups@2022-09-01' = [for vm in param.vm: {
  name: toLower('rg-${vm.name}')
  location: param.location
  tags: {
    Application: vm.tags.Application
    Environment: param.tags.Environment
  }
}]

module vm1 'vm.bicep' = [for (vm, i) in param.vm: {
  scope: rgVm[i]
  name: 'module-${vm.name}'
  params: {
    adminPass: '12345678.abc'
    adminUsername: 'azadmin'
    dataDisks: vm.dataDisks
    imageReference: vm.imageReference
    location: rgVm[i].location
    name: vm.name
    networkInterfaces: vm.networkInterfaces
    osDiskSizeGB: vm.osDiskSizeGB
    plan: vm.plan
    tags: union(rgVm[i].tags, vm.tags)
    vmSize: vm.vmSize
    vnetname: vnet.outputs.name
    vnetrg: rginfra.name
    AzureMonitorAgent: vm.AzureMonitorAgent
    DataLinuxId: datarules.outputs.DataLinuxId
    DataWinId: datarules.outputs.DataWinId
  }
}]

module log 'log.bicep' = {
  name: 'module-${affix}-log'
  scope: rginfra
  params: {
    name: 'log-${affix}-01'
    location: param.location
    sku: param.log.sku
    retentionInDays: param.log.retention
    solutions: param.log.solutions
    events: param.log.events
  }
}

module datarules 'datarules.bicep' = {
  scope: rginfra
  name: 'module-${affix}-datarules'
  params: {
    location: param.location
    env: env
    workspaceName: log.outputs.name
  }
}
