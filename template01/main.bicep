targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var env = toLower(param.tags.Environment)

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  location: param.location
  tags: param.tags
  name: 'rg-${affix}-01'
}

module vnet 'vnet.bicep' = {
  scope: rg
  name: 'module-vnet'
  params: {
    addressPrefixes: param.vnet.addressPrefixes
    affix: affix
    location: param.location
    subnets: param.vnet.subnets
  }
}
