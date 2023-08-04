targetScope = 'subscription'

param env string
param param object

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-vnet-${env}-01'
  location: param.location
}

resource rgVm 'Microsoft.Resources/resourceGroups@2022-09-01' = [for vm in param.vms: {
  name: 'rg-${vm.name}'
  location: param.location
}]

module vnet 'vnet.bicep' = {
  scope: rg
  name: 'module-vnet'
  params: {
    addressPrefixes: param.vnet.addressPrefixes
    dnsServers: param.vnet.dnsServers
    location: param.location
    name: param.vnet.name
    peerings: param.vnet.peerings
    subnets: param.vnet.subnets
    tags: param.tags
  }
}

module rgAsr 'rgSiteRecovery.bicep' = {
  name: 'module-rg-asr'
  params: {
    env: env
    param: param
  }
}

module vnetAsr 'vnet.bicep' = {
  scope: resourceGroup('rg-siterecovery-${env}-01')
  name: 'module-vnet-asr'
  params: {
    addressPrefixes: param.vnet.addressPrefixes
    dnsServers: param.vnet.dnsServers
    location: param.locationAsr
    name: param.vnet.name
    peerings: param.vnet.peerings
    subnets: param.vnet.subnets
    tags: param.tags
  }
}

module rsvAsr 'rsvSiteRecovery.bicep' = {
  scope: resourceGroup('rg-siterecovery-${env}-01')
  name: 'module-rsv-asr'
  params: {
    asrVnetId: vnetAsr.outputs.id
    name: 'rsv-siterecovery-01'
    primaryLocation: param.location
    secondarylocation: param.locationAsr
    vnetId: vnet.outputs.id
  }
}

module vm 'vm.bicep' = [for (vm, i) in param.vms: {
  scope: rgVm[i]
  name: 'module-${vm.name}'
  params: {
    adminPassword: '12345678.abc'
    adminUsername: 'azadmin'
    asrSubId: subscription().subscriptionId
    computerName: contains(vm, 'computerName') ? vm.computerName : vm.name
    dataDisks: vm.dataDisks
    imageReference: vm.imageReference
    location: param.location
    name: vm.name
    networkInterfaces: vm.networkInterfaces
    osDiskSizeGB: vm.osDiskSizeGB
    plan: vm.plan
    primaryStId: rsvAsr.outputs.primaryStId
    replicationPolicyId: rsvAsr.outputs.replicationPolicy
    rsvAsrName: rsvAsr.outputs.name
    rsvAsrRg: rgAsr.outputs.name
    rsvAsrVnetId: vnetAsr.outputs.id
    siteRecovery: vm.backup.siteRecovery
    vmAsrRg: 'rg-${vm.name}-asr'
    vmSize: vm.vmSize
    vnetname: vnet.outputs.name
    vnetrg: rg.name
    tags: union(param.tags, vm.tags)
  }
}]
