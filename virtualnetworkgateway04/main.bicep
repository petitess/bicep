targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var location = param.location

var secondSubId = 'xxxxxxxx-be27-46a2-9bb0-xxxxxxxxxx'
var secondSubRgInfraName = toLower('rg-infra-prod-sc-01')
var secondSubVgwName = toLower('vgw-infra-prod-01')
var secondSubVgwPip = reference(resourceId(secondSubId, secondSubRgInfraName, 'Microsoft.Network/publicIPAddresses', 'pip-${secondSubVgwName}'), '2022-07-01').ipAddress


resource rginfra 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  location: location
  tags: param.tags
  name: 'rg-${affix}-01'
}

module vnet 'vnet.bicep' = {
  scope: rginfra
  name: 'module-${affix}-vnet01'
  params: {
    addressPrefixes: param.vnet.addressPrefixes
    dnsServers: param.vnet.dnsServers
    location: location
    name: 'vnet-${affix}-01'
    natGateway: param.vnet.natGateway
    peerings: param.vnet.peerings
    subnets: param.vnet.subnets
  }
}

module bas 'bas.bicep' = if (param.bastion) {
  scope: rginfra
  name: 'module-${affix}-bas'
  params: {
    location: param.location
    name: 'bas-${vnet.outputs.name}'
    subnet: '${vnet.outputs.id}/subnets/AzureBastionSubnet'
  }
}

module vgw 'vgw.bicep' = if (param.vgw.deploy) {
  scope: rginfra
  name: 'module-${affix}-vgw1'
  params: {
    name: 'vgw-${affix}-01'
    location: param.location
    subnetid: vnet.outputs.GatewaySubnetId
    param: param
    bgpSettings: param.vgw.bgpSettings
  }
}

module vgwcon 'vgwcon.bicep' = if (param.vgw.deploy) {
  scope: rginfra
  name: 'module-${affix}-vgwcon1'
  dependsOn: [
    vgw
  ]
  params: {
    location: param.location
    name: 'con-${vnet.outputs.name}'
    sharedKey: '12345678abc!'
    virtualNetworkGateway1id: vgw.outputs.vgwid
    localNetworkGateway1id: lgwvnet01.outputs.id
  }
}

resource rgVm 'Microsoft.Resources/resourceGroups@2022-09-01' = [for vm in param.vm: {
  name: toLower('rg-${vm.name}')
  location: param.location
  tags: {
    Application: vm.tags.Application
    Environment: param.tags.Environment
  }
}]

module vm1 'vm.bicep' = [for (vm, i) in param.vm: {
  scope: rgVm[i]
  name: 'module-${vm.name}-vm'
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
    vnetrg: rginfra.name
  }
}]

module lgwvnet01 'lgw.bicep' = if (param.vgw.deploy) {
  scope: rginfra
  name: 'module-${affix}-lgw1'
  params: {
    gatewayIpAddress: secondSubVgwPip
    addressPrefixes: [
      '10.10.0.0/16'
      '81.0.0.0/20'
      '82.0.0.0/18'
      '213.0.0.0/19'
      '10.112.0.0/16'
    ]
    location: location
    name: 'lgw-${affix}-01'
  }
}

module lgwprod 'lgw.bicep' = if (param.vgw.deploy) {
  scope: resourceGroup(secondSubId, secondSubRgInfraName)
  name: 'module-${affix}-lgw1'
  params: {
    // asn: param.vgwvnet01.asn
    // peerWeight: param.vgwvnet01.peerWeight
    gatewayIpAddress: vgw.outputs.pip1id
    addressPrefixes: [
      '10.25.0.0/16'
    ]
    location: location
    name: 'lgw-${affix}-01'
    // bgpPeeringAddress: param.vgwvnet01.bgpPeeringAddress
  }
}

module vgwconprod 'vgwcon.bicep' = if (param.vgw.deploy) {
  scope: resourceGroup(secondSubId, secondSubRgInfraName)
  name: 'module-${affix}-vgwcon3'
  params: {
    location: param.location
    name: 'con-${vnet.outputs.name}'
    sharedKey: '12345678abc!'
    virtualNetworkGateway1id: resourceId(secondSubId, secondSubRgInfraName, 'Microsoft.Network/virtualNetworkGateways', secondSubVgwName)
    localNetworkGateway1id: lgwprod.outputs.id
  }
}

output sub2pip string = reference(resourceId(secondSubId, secondSubRgInfraName, 'Microsoft.Network/publicIPAddresses', 'pip-${secondSubVgwName}'), '2022-07-01').ipAddress
