targetScope = 'subscription'

param param object

var affix = toLower('${param.value.tags.Application}-${param.value.tags.Environment}')
var location = param.value.location
var tags = param.value.tags

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  location: location
  tags: tags
  name: 'rg-${affix}-01'
}

resource rgSt 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  location: location
  tags: tags
  name: 'rg-storage-01'
}

module vnet 'vnet.bicep' = {
  scope: rg
  name: 'module-vnet'
  params: {
    addressPrefixes: param.value.vnet.addressPrefixes
    affix: affix
    location: location
    subnets: param.value.vnet.subnets
  }
}

module st 'st.bicep' = [for st in param.value.storageAccounts: {
  name: 'module-${st.name}'
  scope: rgSt
  params: {
    name: st.name
    location: location
    sku: st.sku
    containersCount: st.containersCount
    shares: st.shares
    publicNetworkAccess: st.publicNetworkAccess
    snetId: vnet.outputs.snet['snet-pep'].id
    policyId: rsv.outputs.filesharePolicy
    rsvName: rsv.outputs.name
    rsvRgName: rg.name
  }
}]

module rsv 'rsv.bicep' = {
  scope: rg
  name: 'module-rsv'
  params: {
    location: location
    name: 'rsv-${affix}-01'
  }
}

output z object = param
output x object = param.value
