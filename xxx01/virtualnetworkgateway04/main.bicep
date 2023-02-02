targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var location = param.location

var subid = 'b2f0f1dc-be27-46a2-9bb0-e80270acfaa0'
var rginfraprod = toLower('rg-infra-prod-sc-01')
var vgwprod = toLower('vgw-infra-prod-01')

resource rginfra 'Microsoft.Resources/resourceGroups@2022-09-01' = {
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

module bas 'bas.bicep' = if (param.bastion) {
  scope: rginfra
  name: 'module-${affix}-bas'
  params: {
    location: param.location
    name: 'bas-${vnet01.outputs.name}'
    subnet: '${vnet01.outputs.id}/subnets/AzureBastionSubnet'
  }
}

module vgwvnet01 'vgw.bicep' = if (param.vgw) {
  scope: rginfra
  name: 'module-${affix}-vgw1'
  params: {
    name: 'vgw-${affix}-01'
    location: param.location
    subnetid: vnet01.outputs.GatewaySubnetId
    param: param
    bgpSettings: param.vgwvnet01.bgpSettings
  }
}

module vgwcon1 'vgwcon.bicep' = if (param.vgw) {
  scope: rginfra
  name: 'module-${affix}-vgwcon1'
  dependsOn: [
    vgwvnet01
  ]
  params: {
    location: param.location
    name: 'con-${vnet01.outputs.name}'
    sharedKey: '12345678abc!'
    virtualNetworkGateway1id: vgwvnet01.outputs.vgwid
    virtualNetworkGateway2id: resourceId(subid, rginfraprod, 'Microsoft.Network/virtualNetworkGateways', vgwprod)
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

// resource vnetprod 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
//   name: 'vnet-infra-prod-01'
//   scope: resourceGroup(subid, rginfraprod)
// }

module vgwcon3 'vgwcon.bicep' = if (param.vgw) {
  scope: resourceGroup(subid, rginfraprod)
  name: 'module-${affix}-vgwcon3'
  dependsOn: [
    vgwvnet01
  ]
  params: {
    location: param.location
    name: 'con-${vnet01.outputs.name}'
    sharedKey: '12345678abc!'
    virtualNetworkGateway1id: resourceId(subid, rginfraprod, 'Microsoft.Network/virtualNetworkGateways', vgwprod)
    virtualNetworkGateway2id: vgwvnet01.outputs.vgwid
  }
}

module vm1 'vm.bicep' = [for (vm, i) in param.vm: {
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
    vnetname: vnet01.outputs.name
    vnetrg: rginfra.name
    extensions: vm.extensions
  }
}]
