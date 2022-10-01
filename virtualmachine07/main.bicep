targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${affix}-sc-01'
  location: param.location
  tags: param.tags
}

resource rgAlt 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${affix}-we-01'
  location: param.locationAlt
  tags: param.tags
}

module vnet01 'vnet.bicep' = {
  scope: rg
  name: 'module-${affix}-vnet01'
  params: {
    addressPrefixes: param.vnet01.addressPrefixes
    dnsServers: param.vnet01.dnsServers
    location: param.location
    name: 'vnet-${affix}-01'
    natGateway: param.vnet01.natGateway
    peerings: param.vnet01.peerings
    subnets: param.vnet01.subnets 
  }
}

module bas 'bas.bicep' = {
  scope: rg
  name: 'module-${affix}-bas'
  params: {
    location: rg.location
    name: 'bas-${vnet01.outputs.name}'
    subnet: '${vnet01.outputs.id}/subnets/AzureBastionSubnet'
  }
}

resource rgVm 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: toLower('rg-vmavd${param.tags.Environment}01')
  location: param.location
  tags: param.tags
}

module vm 'vm.bicep' = [for (vm, i) in param.vm: {
  scope: rgVm
  name: 'module-${vm.name}-vm'
  params: {
    adminPassword: '12345678.abc'
    adminUsername: 'azadmin'
    dataDisks: vm.dataDisks
    imageReference: vm.imageReference
    location: rgVm.location
    name: vm.name
    networkInterfaces: vm.networkInterfaces
    osDiskSizeGB: vm.osDiskSizeGB
    plan: vm.plan
    tags: union(rgVm.tags, vm.tags)
    vmSize: vm.vmSize
    vnetname: vnet01.outputs.name
    vnetrg: rg.name
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

module vmvdaext 'vmvdaext.bicep' = [for (vmvda, i) in range(0, param.vda.numberOfVMs): {
  scope: rgVm
  name: 'module-vda0${vmvda + 1}-vmlog'
  dependsOn: [
    vm
  ]
  params: {
    location: rgVm.location
    name: '${param.vda.prefix}${i +1}'
    log: vmlog.outputs.id
    logApi: vmlog.outputs.api
  }
}]
