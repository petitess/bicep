targetScope = 'subscription'

param param object
var affix = toLower('${param.tags.Application}-${param.tags.Environment}')

resource rginfra1 'Microsoft.Resources/resourceGroups@2021-04-01' ={
  location: param.location
  tags: param.tags
  name: 'rg-${affix}-01'
}

module vnet01 'vnet.bicep' = {
  scope: rginfra1
  name: 'module-${affix}-vnet01'
  params: {
    addressPrefixes: param.vnet01.addressPrefixes
    dnsServers: param.vnet01.dnsServers
    location: param.location
    name: 'vnet-${affix}-01'
    natGateway: param.vnet01.natGateway
    peerings: param.vnet01.peerings
    subnets: param.vnet01.subnets 
  }
}

module bas 'bas.bicep' = {
  scope: rginfra1
  name: 'module-${affix}-bas'
  params: {
    location: param.location
    name: 'bas-${vnet01.outputs.name}'
    subnet: '${vnet01.outputs.id}/subnets/AzureBastionSubnet'
  }
}

resource rgVm 'Microsoft.Resources/resourceGroups@2021-04-01' = [for vm in param.vm: {
  name: toLower('rg-${vm.name}')
  location: param.location
  tags: {
    Application: vm.tags.Application
    Environment: param.tags.Environment
  }
}]

module vm1 'vm.bicep' = [for (vm, i) in param.vm: {
  scope: rgVm[i]
  name: 'module-${vm.name}-vm'
  params: {
    adminPassword: '12345678.abC'
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
    vnetname: vnet01.outputs.name
    vnetrg: rginfra1.name
    extensions: vm.extensions
  }
}]

module log 'log.bicep' = {
  name: 'module-${affix}-log'
  scope: rginfra1
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
  scope: rginfra1
  name: 'module-${affix}-datarules'
  params: {
    location: param.location
    name: '${affix}-sc01'
    workspacename: log.outputs.name
  }
}

module vmassociation 'vmassociation.bicep' = [for (vm, i) in param.vm: {
  scope: rgVm[i]
  name: 'module-${vm.name}-vmassociation'
  params: {
    associationName: 'data-${vm.name}'
    DataWinId: datarules.outputs.DataWinId
    DataLinuxId: datarules.outputs.DataLinuxId
    vmname: vm.name
    extensions: vm.extensions 
    publisher: vm.imageReference.publisher
  }
}]
