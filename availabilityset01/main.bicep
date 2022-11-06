targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var location = param.location

resource rginfra 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: location
  tags: param.tags
  name: 'rg-${affix}-01'
}

module vnet 'vnet.bicep' = {
  scope: rginfra
  name: 'module-${affix}-vnet01'
  params: {
    addressPrefixes: param.vnet.addressPrefixes
    dnsServers: param.vnet.dnsServers
    location: location
    name: 'vnet-${affix}-01'
    natGateway: param.vnet.natGateway
    peerings: param.vnet.peerings
    subnets: param.vnet.subnets 
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

module vm 'vm.bicep' = [for (vm, i) in param.vm: {
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
    vnetname: vnet.outputs.name
    vnetrg: rginfra.name
    availabilityset: vm.availabilityset
    availabilitySetId: avail[i].outputs.id
  }
}]

module avail 'avail.bicep' = [for (vm, i) in param.vm: {
  scope: rgVm[i]
  name: 'module-vm-avail'
  params: {
    location: param.location
    name: vm.name
  }
}]
