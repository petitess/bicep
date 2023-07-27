targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var env = toLower(param.tags.Environment)
var app = toLower(param.tags.Application)
var location = param.location

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' ={
  location: location
  tags: param.tags
  name: 'rg-vnet-${env}-01'
}

resource rgPlan 'Microsoft.Resources/resourceGroups@2022-09-01' ={
  location: location
  tags: param.tags
  name: 'rg-${app}-${env}-01'
}

module vnet 'vnet.bicep' = {
  scope: rg
  name: 'module-vnet'
  params: {
    addressPrefixes: param.vnet.addressPrefixes
    affix: affix
    location: location
    subnets: param.vnet.subnets
  }
}

module plan 'app.bicep' = {
  scope: rgPlan
  name: 'module-plan'
  params: {
    location: location
    affix: affix
    virtualNetworkSubnetId: vnet.outputs.snet['snet-outbound'].id
    snetPepId: vnet.outputs.snet['snet-inbound'].id
  }
}
