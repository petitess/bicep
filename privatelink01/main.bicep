targetScope = 'subscription'

param param object
var affix = toLower('${param.tags.Application}-${param.tags.Environment}')

resource rginfra1 'Microsoft.Resources/resourceGroups@2021-04-01' ={
  location: param.location
  tags: param.tags
  name: 'rg-infra-${affix}-01'
}

resource rginfra2 'Microsoft.Resources/resourceGroups@2021-04-01' ={
  location: param.locationAlt
  tags: param.tags
  name: 'rg-infra-${affix}-02'
}

module vnet01 'vnet.bicep' = {
  scope: rginfra1
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

module vnet02 'vnet.bicep' = {
  scope: rginfra2
  name: 'module-${affix}-vnet02'
  params: {
    addressPrefixes: param.vnet02.addressPrefixes
    dnsServers: param.vnet02.dnsServers
    location: param.locationAlt
    name: 'vnet-${affix}-02'
    natGateway: param.vnet02.natGateway
    peerings: param.vnet02.peerings
    subnets: param.vnet02.subnets 
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
    adminPassword: '12345678.abC'
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

  }
}]

resource rgVm2 'Microsoft.Resources/resourceGroups@2021-04-01' = [for vm in param.vmvnet02: {
  name: toLower('rg-${vm.name}')
  location: param.locationAlt
  tags: {
    Application: vm.tags.Application
    Environment: param.tags.Environment
  }
}]

module vm2 'vm.bicep' = [for (vm, i) in param.vmvnet02: {
  scope: rgVm2[i]
  name: 'module-${vm.name}-vm'
  params: {
    adminPassword: '12345678.abC'
    adminUsername: 'azadmin'
    dataDisks: vm.dataDisks
    imageReference: vm.imageReference
    location: rgVm2[i].location
    name: vm.name
    networkInterfaces: vm.networkInterfaces
    osDiskSizeGB: vm.osDiskSizeGB
    plan: vm.plan
    tags: union(rgVm2[i].tags, vm.tags)
    vmSize: vm.vmSize
    vnet: vnet02.outputs.id

  }
}]

module lb 'lb.bicep' = {
  scope: rginfra1
  name: 'module-${affix}-lb01'
  params: {
    backendAddressPools: param.lb.backendAddressPools
    location: param.location
    name: 'lbi-${affix}-01'
    privateIPAddress: param.lb.privateIPAddress
    subnetid: '${subscription().id}/resourceGroups/${rginfra1.name}/providers/Microsoft.Network/virtualNetworks/${vnet01.outputs.name}/subnets/${param.lb.subnetname}'
    probes: param.lb.probes
  }
}

module pe 'pe.bicep' = {
  scope: rginfra2
  name: 'module-${affix}-pe'
  params: {
    location: param.locationAlt
    name: 'pe-${affix}-02'
    privateLinkServiceId: lb.outputs.plid
    subnet: vnet02.outputs.pesubnetname
    vnet: vnet02.outputs.id
  }
}
