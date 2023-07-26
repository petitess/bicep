targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var env = toLower(param.tags.Environment)
var location = param.location

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' ={
  location: location
  tags: param.tags
  name: 'rg-${affix}-01'
}

resource rgAks01 'Microsoft.Resources/resourceGroups@2022-09-01' ={
  location: location
  tags: param.tags
  name: 'rg-aks-${env}-01'
}

module vnet 'vnet.bicep' = {
  scope: rg 
  name: 'module-vnet'
  params: {
    affix: affix
    location: location
  }
}

module aks 'aks.bicep' = {
  scope: rgAks01
  name: 'module-aks'
  params: {
    name: 'aks-${env}-01'
    location: location
    nodeRg: 'rg-aks-node-${env}-01'
    snetId: vnet.outputs.snet['snet-aks-01'].id
  }
}
