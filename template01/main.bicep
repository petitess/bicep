targetScope = 'subscription'

param param object
var affix = toLower('${param.tags.Application}-${param.tags.Environment}')

var rgs = [
  'rg-${affix}-01'
  'rg-${affix}-02'
]

resource rgvnet 'Microsoft.Resources/resourceGroups@2021-04-01' =   [for rg in rgs: {
  location: param.location
  tags: param.tags
  name: rg
}]

module vnet01 'vnet.bicep' = {
  scope: rgvnet[0]
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
  scope: rgvnet[1]
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
