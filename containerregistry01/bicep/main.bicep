targetScope = 'subscription'

param env string
param location string
param tags object
param vnet object
param vms array
param existingVMs array = []

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  location: location
  tags: tags
  name: 'rg-${env}-01'
}

resource rgAcr 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  location: location
  tags: tags
  name: 'rg-acr-${env}-01'
}

module vnetM 'vnet.bicep' = {
  scope: rg
  name: 'vnet'
  params: {
    addressPrefixes: vnet.addressPrefixes
    dnsServers: vnet.dnsServers
    location: location
    name: 'vnet-${env}-01'
    natGateway: vnet.natGateway
    peerings: vnet.peerings
    subnets: vnet.subnets
  }
}

module bas 'bas.bicep' = if (false) {
  scope: rg
  name: 'bas'
  params: {
    location: location
    name: 'bas-${vnetM.outputs.name}'
    subnet: vnetM.outputs.snet.AzureBastionSubnet.id
    vnetId: vnetM.outputs.id
  }
}

resource rgVm 'Microsoft.Resources/resourceGroups@2023-07-01' = [for vm in vms: {
  name: toLower('rg-${vm.name}')
  location: location
  tags: {
    Application: vm.tags.Application
    Environment: tags.Environment
  }
}]

module vm 'vm.bicep' = [for (vm, i) in vms: if (true) {
  scope: rgVm[i]
  name: vm.name
  params: {
    adminPass: '12345.abc'
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
    vnetName: vnetM.outputs.name
    vnetRg: rg.name
  }
}]

module acr 'acr.bicep' = {
  scope: rgAcr
  name: 'acr'
  params: {
    location: location
    name: 'acrdocker${env}01'
    tags: tags
  }
}

resource vmDocker 'Microsoft.Compute/virtualMachines@2023-09-01' existing = if (contains(existingVMs, 'vmdevops01')) {
  name: 'vmdevops01'
  scope: resourceGroup(contains(existingVMs, 'vmdevops01') ? 'rg-vmdevops01' : 'rg-${env}-01')
}

module rbacM 'rbac.bicep' = if (contains(existingVMs, 'vmdevops01')) {
  scope: rgAcr
  name: 'rbac-acr'
  params: {
    principalId: contains(existingVMs, 'vmdevops01') ? vmDocker.identity.principalId : ''
    roles: [
      'AcrPull'
      'AcrPush'
    ]
  }
}

resource vmDocker2 'Microsoft.Compute/virtualMachines@2023-09-01' existing = if (contains(existingVMs, 'vmdevops02')) {
  name: 'vmdevops02'
  scope: resourceGroup(contains(existingVMs, 'vmdevops02') ? 'rg-vmdevops02' : 'rg-${env}-01')
}

module rbacM2 'rbac.bicep' = if (contains(existingVMs, 'vmdevops02')) {
  scope: rgAcr
  name: 'rbac-acr2'
  params: {
    principalId: contains(existingVMs, 'vmdevops02') ? vmDocker2.identity.principalId : ''
    roles: [
      'AcrPull'
      'AcrPush'
    ]
  }
}

output existingVMs array = existingVMs
output dockerExists bool = contains(existingVMs, 'vmdevops01')
output dockerExists2 bool = contains(existingVMs, 'vmdevops02')
