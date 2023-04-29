targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  location: param.location
  tags: param.tags
  name: 'rg-${affix}-01'
}

resource rgSt 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  location: param.location
  tags: param.tags
  name: 'rg-storage-01'
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

module st 'st.bicep' = [for st in param.storageAccounts: {
  name: 'module-${st.name}'
  scope: rgSt
  params: {
    name: st.name
    location: param.location
    sku: st.sku
    containersCount: st.containersCount
    shares: st.shares
    publicNetworkAccess: st.publicNetworkAccess
    snetId: vnet.outputs.snet['snet-pep'].id
  }
}]
