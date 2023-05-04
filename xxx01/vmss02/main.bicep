targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var env = toLower(param.tags.Environment)

var deployBastion = false

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

module bastion 'bas.bicep' = if(deployBastion) {
  scope: rg
  name: 'module-bastion'
  params: {
    location: param.location
    name: 'bas-${env}-01'
    subnet: vnet.outputs.snet.AzureBastionSubnet.id
    vnet: vnet.outputs.id
  }
}

resource rgvmss 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: toLower('rg-vmss-${env}-01')
  location: param.location
  tags: {
    Application: 'VMSS DevOps'
    Environment: param.tags.Environment
  }
}

module vmss 'vmss.bicep' = [for (vm, i) in param.vmss: {
  scope: rgvmss
  name: 'module-${vm.name}'
  params: {
    adminPass: '12345678.abc'
    adminUsername: 'azadmin'
    capacity: vm.capacity
    computerNamePrefix: vm.prefix
    dataDisks: vm.dataDisks
    imageReference: vm.imageReference
    location: rgvmss.location
    name: vm.name
    networkInterfaces: vm.networkInterfaces
    osDiskSizeGB: vm.osDiskSizeGB
    plan: vm.plan
    tags: union(rgvmss.tags, vm.tags)
    vmSize: vm.vmSize
    deployDevOpsAgent: vm.deployDevOpsAgent
    vnetname: vnet.outputs.name
    vnetrg: rg.name
  }
}]
