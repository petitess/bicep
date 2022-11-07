targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var env = toLower(param.tags.Environment)

resource rginfra 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: param.location
  tags: param.tags
  name: 'rg-${affix}-01'
}

module vnet 'vnet.bicep' = {
  scope: rginfra
  name: 'module-${affix}-vnet01'
  params: {
    addressPrefixes: param.vnet.addressPrefixes
    dnsServers: param.vnet.dnsServers
    location: rginfra.location
    name: 'vnet-${affix}-01'
    natGateway: param.vnet.natGateway
    peerings: param.vnet.peerings
    subnets: param.vnet.subnets 
  }
}

resource rgVm 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: toLower('rg-vmapp${env}01')
  location: param.location
  tags: {
    Application: 'App${env}01'
    Environment: param.tags.Environment
  }
}

module vm 'vm.bicep' = [for (vm, i) in param.vm: {
  scope: rgVm
  name: 'module-${vm.name}-vm'
  params: {
    adminPassword: '12345678.abc'
    adminUsername: 'azadmin'
    dataDisks: vm.dataDisks
    imageReference: vm.imageReference
    location: rgVm.location
    name: vm.name
    networkInterfaces: vm.networkInterfaces
    osDiskSizeGB: vm.osDiskSizeGB
    plan: vm.plan
    tags: union(rgVm.tags, vm.tags)
    vmSize: vm.vmSize
    vnetname: vnet.outputs.name
    vnetrg: rginfra.name
    availabilityset: vm.availabilityset
    availabilitySetId: avail.outputs.id
  }
}]

module avail 'avail.bicep' = {
  scope: rgVm
  name: 'module-vmapp-avail'
  params: {
    location: param.location
    name: 'avail-adc-${env}-01'
  }
}
