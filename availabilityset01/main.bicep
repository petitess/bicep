targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var env = toLower(param.tags.Environment)

resource rgInfra 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  location: param.location
  tags: param.tags
  name: 'rg-${affix}-01'
}

module vnet 'vnet.bicep' = {
  scope: rgInfra
  name: 'module-${affix}-vnet01'
  params: {
    addressPrefixes: param.vnet.addressPrefixes
    dnsServers: param.vnet.dnsServers
    location: rgInfra.location
    name: 'vnet-${affix}-01'
    natGateway: param.vnet.natGateway
    peerings: param.vnet.peerings
    subnets: param.vnet.subnets 
  }
}

resource rgVm 'Microsoft.Resources/resourceGroups@2022-09-01' =[for rg in param.noAvailabilitySets:  {
  name: 'rg-${rg}'
  location: param.location
  tags: param.tags
}]

resource rgAvail 'Microsoft.Resources/resourceGroups@2022-09-01' = [for rg in param.availabilitySets: {
  name: 'rg-${rg}'
  location: param.location
  tags: param.tags
}]

module avail 'avail.bicep' = [for (avail, i) in param.availabilitySets: {
  scope: rgAvail[i]
  name: 'module-vmavail-${env}'
  params: {
    location: param.location
    name: 'avail-${avail}'
  }
}]

module vm 'vm.bicep' = [for (vm, i) in param.vm: {
  scope: resourceGroup(vm.rgName)
  name: 'module-${vm.name}'
  params: {
    adminPass: '12345678.abc'
    adminUsername: 'azadmin'
    dataDisks: vm.dataDisks
    imageReference: vm.imageReference
    location: param.location
    name: vm.name
    networkInterfaces: vm.networkInterfaces
    osDiskSizeGB: vm.osDiskSizeGB
    plan: vm.plan
    tags: union(param.tags, vm.tags)
    vmSize: vm.vmSize
    vnetname: vnet.outputs.name
    vnetrg: rgInfra.name
    availabilitySetName: vm.availabilitySetName
  }
}]


