targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var env = toLower(param.tags.Environment)
var rgavail = [
  'rg-vmdc${env}01'
  'rg-vmctx${env}01'
  'rg-vmpvs${env}01'
]

resource rginfra 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: param.location
  tags: param.tags
  name: 'rg-${affix}-02'
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

resource rgavailx 'Microsoft.Resources/resourceGroups@2021-04-01' = [for rg in rgavail: {
  name: rg
  location: param.location
  tags: param.tags
}]

module avail 'avail.bicep' = [for (rg, i) in rgavail: {
  scope: rgavailx[i]
  name: 'module-vmavail'
  params: {
    location: param.location
    name: 'avail-${replace(rg, 'rg-','')}'
  }
}]

module vmdc 'vm.bicep' = [for (vm, i) in param.vmdc: {
  scope: rgavailx[0]
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
    tags: union(rgavailx[0].tags, vm.tags)
    vmSize: vm.vmSize
    vnetname: vnet.outputs.name
    vnetrg: rginfra.name
    availabilityset: vm.availabilityset
    availabilitySetId: resourceId(subscription().subscriptionId, rgavailx[0].name, 'Microsoft.Compute/availabilitySets', 'avail-${replace(rgavail[0], 'rg-','')}')
  }
}]

module vmctx 'vm.bicep' = [for (vm, i) in param.vmctx: {
  scope: rgavailx[1]
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
    tags: union(rgavailx[1].tags, vm.tags)
    vmSize: vm.vmSize
    vnetname: vnet.outputs.name
    vnetrg: rginfra.name
    availabilityset: vm.availabilityset
    availabilitySetId: resourceId(subscription().subscriptionId, rgavailx[1].name, 'Microsoft.Compute/availabilitySets', 'avail-${replace(rgavail[1], 'rg-','')}')
  }
}]


