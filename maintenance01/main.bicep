targetScope = 'subscription'

param param object
var affix = toLower('${param.tags.Application}-${param.tags.Environment}')

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' ={
  location: param.location
  tags: param.tags
  name: 'rg-${affix}-01'
}

module vnet 'vnet.bicep' = {
  scope: rg
  name: 'vnet'
  params: {
    addressPrefixes: param.vnet.addressPrefixes
    dnsServers: param.vnet.dnsServers
    location: param.location
    affix: affix
    peerings: param.vnet.peerings
    subnets: param.vnet.subnets 
  }
}

resource rgVm 'Microsoft.Resources/resourceGroups@2023-07-01' = [for vm in param.vm: {
  name: toLower('rg-${vm.name}')
  location: param.location
  tags: {
    Application: vm.tags.Application
    Environment: param.tags.Environment
  }
}]

module vm 'vm.bicep' = [for (vm, i) in param.vm: {
  scope: rgVm[i]
  name: vm.name
  params: {
    adminPass: '12345678.abc'
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
    vnetrg: rg.name
  }
}]

module mc 'maintenance.bicep' = [for mc in param.maintenanceConfigurations: {
  scope: rg
  name: mc.name
  params: {
    name: mc.name
    location: param.location
    detectionTags: mc.detectionTags
    recurEvery: mc.recurEvery
  }
}]
