targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var location = param.location

resource rginfra 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: location
  tags: param.tags
  name: 'rg-${affix}-01'
}

module vnet01 'vnet.bicep' = {
  scope: rginfra
  name: 'module-${affix}-vnet01'
  params: {
    addressPrefixes: param.vnet01.addressPrefixes
    dnsServers: param.vnet01.dnsServers
    location: location
    name: 'vnet-${affix}-01'
    natGateway: param.vnet01.natGateway
    peerings: param.vnet01.peerings
    subnets: param.vnet01.subnets 
  }
}

module bas 'bas.bicep' = {
  scope: rginfra
  name: 'module-${affix}-bas'
  params: {
    location: param.location
    name: 'bas-${vnet01.outputs.name}'
    subnet: '${vnet01.outputs.id}/subnets/AzureBastionSubnet'
  }
}

resource rgVm 'Microsoft.Resources/resourceGroups@2021-04-01' = [for vm in param.vmvnet01: {
  name: toLower('rg-${vm.name}')
  location: param.location
  tags: {
    Application: vm.tags.Application
    Environment: param.tags.Environment
  }
}]

module vm1 'vm.bicep' = [for (vm, i) in param.vmvnet01: {
  scope: rgVm[i]
  name: 'module-${vm.name}-vm'
  params: {
    adminPassword: '12345678.abc'
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
    vnet: vnet01.outputs.id
    ADDservices: vm.ADDservices
  }
}]
