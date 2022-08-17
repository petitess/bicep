targetScope = 'subscription'

param param object
var affix = toLower('${param.tags.Application}-${param.tags.Environment}')

resource rginfra1 'Microsoft.Resources/resourceGroups@2021-04-01' ={
  location: param.location
  tags: param.tags
  name: 'rg-infra-${affix}-01'
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

module plan 'plan.bicep' = {
  scope: rginfra1
  name:  'module-${affix}-plan'
  params: {
    location: param.location
    name: 'plan-${affix}-01'
    SubnetId: vnet01.outputs.AppSubId
  }
}
