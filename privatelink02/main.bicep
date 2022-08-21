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

resource rginfra2 'Microsoft.Resources/resourceGroups@2021-04-01' ={
  location: param.location
  tags: param.tags
  name: 'rg-${affix}-02'
}

module vnet02 'vnet.bicep' = {
  scope: rginfra2
  name: 'module-${affix}-vnet02'
  params: {
    addressPrefixes: param.vnet02.addressPrefixes
    dnsServers: param.vnet02.dnsServers
    location: param.location
    name: 'vnet-${affix}-02'
    natGateway: param.vnet02.natGateway
    peerings: param.vnet02.peerings
    subnets: param.vnet02.subnets 
  }
}

resource rginfra3 'Microsoft.Resources/resourceGroups@2021-04-01' ={
  location: param.locationAlt
  tags: param.tags
  name: 'rg-${affix}-03'
}

module vnet03 'vnet.bicep' = {
  scope: rginfra3
  name: 'module-${affix}-vnet03'
  params: {
    addressPrefixes: param.vnet03.addressPrefixes
    dnsServers: param.vnet03.dnsServers
    location: param.locationAlt
    name: 'vnet-${affix}-03'
    natGateway: param.vnet03.natGateway
    peerings: param.vnet03.peerings
    subnets: param.vnet03.subnets 
  }
}

module peer01 'peer.bicep' = {
  scope: rginfra
  name: 'module-${affix}-peer01'
  params: {
    vnet01existingname: vnet01.outputs.name
    vnet02existingname: vnet02.outputs.name
    vnet02rg: rginfra2.name
  }
}

module peer02 'peer2.bicep' = {
  scope: rginfra2
  name: 'module-${affix}-peer02'
  params: {
    vnet01existingname: vnet01.outputs.name
    vnet02existingname: vnet02.outputs.name
    vnet01rg: rginfra.name
  }
}

module vgwvnet01 'vgw.bicep' = {
  scope: rginfra
  name: 'module-${affix}-vgw1'
  params: {
    name: 'vgw-${affix}-01'
    location: param.location
    subnetid: vnet01.outputs.GatewaySubnetId
    param: param
    sharedKey: '12345678abc!'
    conname: 'con-${vnet01.outputs.name}'
    bgpSettings: param.vgwvnet01.bgpSettings
    secondaryvgwid: '${subscription().id}/resourceGroups/${rginfra3.name}/providers/Microsoft.Network/virtualNetworkGateways/vgw-${affix}-03'
  }
}

module vgwvnet03 'vgw.bicep' = {
  scope: rginfra3
  name: 'module-${affix}-vgw3'
  params: {
    name: 'vgw-${affix}-03'
    location: param.locationAlt
    subnetid: vnet03.outputs.GatewaySubnetId
    param: param
    sharedKey: '12345678abc!'
    conname: 'con-${vnet03.outputs.name}'
    bgpSettings: param.vgwvnet03.bgpSettings
    secondaryvgwid: '${subscription().id}/resourceGroups/${rginfra.name}/providers/Microsoft.Network/virtualNetworkGateways/vgw-${affix}-01'
  }
}

module st01 'st.bicep' = [for storage in param.st: {
  scope: rginfra2
  name: 'module-${storage.name}'
  params: {
    kind: storage.kind
    location: location
    name: storage.name
    sku: storage.sku
    fileShares: storage.fileShares
    containers: storage.containers
    networkAcls: storage.networkAcls
    appsubnetid: vnet02.outputs.AppSubnetId
  }
}]

module pevnet01 'pe.bicep' = [for storage in param.st: if (storage.pe.enabled) {
  scope: rginfra
  name: 'module-${storage.name}-pe1'
  dependsOn: [
    st01
  ]
  params: {
    groupIds: storage.pe.groupIds
    location: param.location
    name: 'pe-${storage.name}x'
    privateLinkServiceId: '${rginfra2.id}/providers/Microsoft.Storage/storageAccounts/${storage.name}'
    subnet: vnet01.outputs.PeSubnetName
    vnet: vnet01.outputs.id
  }
}]

module pevnet02 'pe.bicep' = [for storage in param.st: if (storage.pe.enabled) {
  scope: rginfra2
  name: 'module-${storage.name}-pe2'
  dependsOn: [
    st01
  ]
  params: {
    groupIds: storage.pe.groupIds
    location: param.location
    name: 'pe-${storage.name}'
    privateLinkServiceId: '${rginfra2.id}/providers/Microsoft.Storage/storageAccounts/${storage.name}'
    subnet: storage.pe.subnet
    vnet: vnet02.outputs.id
  }
}]

module pevnet03 'pe.bicep' = [for storage in param.st: if (storage.pe.enabled) {
  scope: rginfra3
  name: 'module-${storage.name}-pe3'
  dependsOn: [
    st01
  ]
  params: {
    groupIds: storage.pe.groupIds
    location: param.locationAlt
    name: 'pe-${storage.name}y'
    privateLinkServiceId: '${rginfra2.id}/providers/Microsoft.Storage/storageAccounts/${storage.name}'
    subnet: vnet03.outputs.PeSubnetName
    vnet: vnet03.outputs.id
  }
}]

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
  location: param.location
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

resource rgVm3 'Microsoft.Resources/resourceGroups@2021-04-01' = [for vm in param.vmvnet03: {
  name: toLower('rg-${vm.name}')
  location: param.locationAlt
  tags: {
    Application: vm.tags.Application
    Environment: param.tags.Environment
  }
}]

module vm3 'vm.bicep' = [for (vm, i) in param.vmvnet03: {
  scope: rgVm3[i]
  name: 'module-${vm.name}-vm'
  params: {
    adminPassword: '12345678.abC'
    adminUsername: 'azadmin'
    dataDisks: vm.dataDisks
    imageReference: vm.imageReference
    location: rgVm3[i].location
    name: vm.name
    networkInterfaces: vm.networkInterfaces
    osDiskSizeGB: vm.osDiskSizeGB
    plan: vm.plan
    tags: union(rgVm3[i].tags, vm.tags)
    vmSize: vm.vmSize
    vnet: vnet03.outputs.id
  }
}]


