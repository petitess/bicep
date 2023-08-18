targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var env = toLower(param.tags.Environment)

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  location: param.location
  tags: param.tags
  name: 'rg-${affix}-01'
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

module bastion 'bas.bicep' = if(false) {
  scope: rg
  name: 'module-bastion'
  params: {
    location: param.location
    name: 'bas-${env}-01'
    subnet: vnet.outputs.snet.AzureBastionSubnet.id
    vnetId: vnet.outputs.id
  }
}

resource rgVm 'Microsoft.Resources/resourceGroups@2022-09-01' = [for (vm, i) in param.vm: {
  name: 'rg-${vm.name}'
  location: param.location
  tags: param.tags
}]

module vm 'vm.bicep' = [for (vm, i) in param.vm: {
  scope: rgVm[i]
  name: 'module-${vm.name}'
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
    tags: union(param.tags, vm.tags)
    vmSize: vm.vmSize
    vnetName: vnet.outputs.name
    vnetRg: rg.name
  }
}]
