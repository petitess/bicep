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

module vgwvnet01 'vgw.bicep' = {
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

module vgwvnet03 'vgw.bicep' = {
  scope: rginfra3
  name: 'module-${affix}-vgw3'
  params: {
    name: 'vgw-${affix}-03'
    location: param.locationAlt
    subnetid: vnet03.outputs.GatewaySubnetId
    param: param
    bgpSettings: param.vgwvnet03.bgpSettings
    }
}

module vgwcon1 'vgwcon.bicep' = {
  scope: rginfra
  name: 'module-${affix}-vgwcon1'
  dependsOn: [
    vgwvnet01
    vgwvnet03
  ]
  params: {
    location: param.location
    name: 'con-${vnet01.outputs.name}'
    sharedKey: '12345678abc!'
    virtualNetworkGateway1id: vgwvnet01.outputs.vgwid
    virtualNetworkGateway2id: vgwvnet03.outputs.vgwid
  }
}

module vgwcon3 'vgwcon.bicep' = {
  scope: rginfra3
  name: 'module-${affix}-vgwcon3'
  dependsOn: [
    vgwvnet01
    vgwvnet03
  ]
  params: {
    location: param.locationAlt
    name: 'con-${vnet03.outputs.name}'
    sharedKey: '12345678abc!'
    virtualNetworkGateway1id: vgwvnet03.outputs.vgwid
    virtualNetworkGateway2id: vgwvnet01.outputs.vgwid
  }
}
