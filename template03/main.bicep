targetScope = 'subscription'

param env string
param location string
param tags object
param vnet object
param vms array

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  location: location
  tags: tags
  name: 'rg-vnet-${env}-01'
}

module vnetM 'vnet.bicep' = {
  scope: rg
  name: 'vnet'
  params: {
    addressPrefixes: vnet.addressPrefixes
    env: env
    location: location
    subnets: vnet.subnets
  }
}

module bastion 'bas.bicep' = if (false) {
  scope: rg
  name: 'bastion'
  params: {
    location: location
    name: 'bas-${env}-01'
    subnet: vnet.outputs.snet.AzureBastionSubnet.id
    vnetId: vnet.outputs.id
  }
}

resource rgVm 'Microsoft.Resources/resourceGroups@2023-07-01' = [for (vm, i) in vms: {
  name: 'rg-${vm.name}'
  location: location
  tags: tags
}]

module vm 'vm.bicep' = [for (vm, i) in vms: {
  scope: rgVm[i]
  name: vm.name
  params: {
    adminPassword: '12345.abc'
    adminUsername: 'azadmin'
    dataDisks: vm.dataDisks
    imageReference: vm.imageReference
    location: location
    name: vm.name
    networkInterfaces: vm.networkInterfaces
    osDiskSizeGB: vm.osDiskSizeGB
    plan: vm.plan
    tags: union(tags, vm.tags)
    vmSize: vm.vmSize
    vnetName: vnetM.outputs.name
    vnetRg: rg.name
  }
}]
