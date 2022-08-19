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

