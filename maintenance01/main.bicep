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
    adminPassword: '12345678.abc'
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
  }
}]

module maintenance 'maintenance.bicep' = {
  scope: rginfra1
  name: 'module-${affix}-maintenance'
  params: {
    name: toLower('update-${param.tags.Environment}-01')
    location: param.location
  }
}

module vmassignments 'vmassignments.bicep' = [ for (vm, i) in param.vm: if(vm.imageReference.publisher != 'canonical') {
  scope: rgVm[i]
  name: 'module-${vm.name}-vmassignments'
  params: {
    maintenanceid: maintenance.outputs.maintenanceid
    name: vm.name
    param: param
  }
}]

