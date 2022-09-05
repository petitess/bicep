targetScope = 'subscription'

param param object
var affix = toLower('${param.tags.Application}-${param.tags.Environment}')

resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: 'rg-${affix}-sc-01'
  location: param.location
  tags: param.tags
}

module vnet 'vnet.bicep' = {
  scope: rg
  name: 'module-${affix}-vnet'
  params: {
    addressPrefixes: param.vnet.addressPrefixes
    dnsServers: param.vnet.dnsServers
    location: param.location
    name: 'vnet-${affix}-01'
    natGateway: param.vnet.natGateway
    peerings: param.vnet.peerings
    subnets: param.vnet.subnets
  }
}

resource rgf 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-test01'
  location: param.location
  tags: {
   ABC : tenant().tenantId

  }
}

module vgw 'vgw.bicep' = {
  scope: rg
  name: 'module-${affix}-vgw'
  params: {
    name: 'vgw-${affix}-01'
    subnetid: vnet.outputs.GatewaySubnetId
    param: param
  }
}

