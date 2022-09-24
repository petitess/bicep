targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')

resource rgvnet01 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: param.location
  tags: param.tags
  name: 'rg-${affix}-sc-01'
}

resource rgAlt 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${affix}-we-01'
  location: param.locationAlt
  tags: param.tags
}

module vnet01 'vnet.bicep' = {
  scope: rgvnet01
  name: 'module-${affix}-vnet01'
  params: {
    addressPrefixes: param.vnet01.addressPrefixes
    dnsServers: param.vnet01.dnsServers
    location: rgvnet01.location
    name: 'vnet-${affix}-01'
    natGateway: param.vnet01.natGateway
    peerings: param.vnet01.peerings
    subnets: param.vnet01.subnets 
  }
}

resource rgVm 'Microsoft.Resources/resourceGroups@2021-04-01' = [for vm in param.vm: {
  name: toLower('rg-${vm.name}')
  location: param.location
  tags: {
    Application: vm.tags.Application
    Environment: param.tags.Environment
  }
}]

module vm 'vm.bicep' = [for (vm, i) in param.vm: {
  scope: rgVm[i]
  name: 'module-${vm.name}-vm'
  params: {
    adminPassword: '12345678.abc'
    adminUsername: 'azadmin'
    dataDisks: vm.dataDisks
    extensions: vm.extensions
    imageReference: vm.imageReference
    location: rgVm[i].location
    log: vmlog.outputs.id
    logApi: vmlog.outputs.api
    name: vm.name
    networkInterfaces: vm.networkInterfaces
    osDiskSizeGB: vm.osDiskSizeGB
    plan: vm.plan
    tags: union(rgVm[i].tags, vm.tags)
    vmSize: vm.vmSize
    vnetname: vnet01.outputs.name
    vnetrg: rgvnet01.name
  }
}]

module vmlog 'vmLog.bicep' = {
  scope: rgAlt
  name: 'module-${affix}-vmlog'
  params: {
    location: rgAlt.location
    name: 'log-vm-${affix}-01'
    aaid: vmaa.outputs.aaid
  }
}

module vmaa 'vmAa.bicep' = {
  scope: rgAlt
  name: 'module-${affix}-vmaa'
  params: {
    location: rgAlt.location
    name: 'aa-vm-${affix}-01'
    updateSchedules: param.updateSchedules
  }
}
