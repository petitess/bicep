targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var env = toLower(param.tags.Environment)
var availabilitysets = [
  'vmdc${env}01'
  'vmctx${env}01'
  'vmpvs${env}01'
]

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

resource rgavail 'Microsoft.Resources/resourceGroups@2021-04-01' = [for rg in availabilitysets: {
  name: 'rg-${rg}'
  location: param.location
  tags: param.tags
}]

module avail 'avail.bicep' = [for (avail, i) in availabilitysets: {
  scope: rgavail[i]
  name: 'module-vmavail'
  params: {
    location: param.location
    name: 'avail-${avail}'
  }
}]

module vmdc 'vm.bicep' = [for (vm, i) in param.vmdc: {
  scope: rgavail[0]
  name: 'module-${vm.name}-vm'
  params: {
    adminPassword: '12345678.abc'
    adminUsername: 'azadmin'
    dataDisks: vm.dataDisks
    imageReference: vm.imageReference
    location: param.location
    name: vm.name
    networkInterfaces: vm.networkInterfaces
    osDiskSizeGB: vm.osDiskSizeGB
    plan: vm.plan
    tags: union(rgavail[0].tags, vm.tags)
    vmSize: vm.vmSize
    vnetname: vnet.outputs.name
    vnetrg: rginfra.name
    availabilityset: vm.availabilityset
    availabilitySetId: resourceId(subscription().subscriptionId, rgavail[0].name, 'Microsoft.Compute/availabilitySets', 'avail-${availabilitysets[0]}')
  }
}]

module vmctx 'vm.bicep' = [for (vm, i) in param.vmctx: {
  scope: rgavail[1]
  name: 'module-${vm.name}-vm'
  params: {
    adminPassword: '12345678.abc'
    adminUsername: 'azadmin'
    dataDisks: vm.dataDisks
    imageReference: vm.imageReference
    location: param.location
    name: vm.name
    networkInterfaces: vm.networkInterfaces
    osDiskSizeGB: vm.osDiskSizeGB
    plan: vm.plan
    tags: union(rgavail[1].tags, vm.tags)
    vmSize: vm.vmSize
    vnetname: vnet.outputs.name
    vnetrg: rginfra.name
    availabilityset: vm.availabilityset
    availabilitySetId: resourceId(subscription().subscriptionId, rgavail[1].name, 'Microsoft.Compute/availabilitySets', 'avail-${availabilitysets[1]}')
  }
}]


