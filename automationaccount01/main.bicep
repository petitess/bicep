targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var location = param.location

resource rginfra 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: location
  tags: param.tags
  name: 'rg-${affix}-01'
}

module rsv 'rsv.bicep' = {
  scope: rginfra
  name: 'module-${affix}-rsv01'
  params: {
    location: location
    name: 'rsv-${affix}-01'
  }
}

module st01 'st.bicep' = [for storage in param.st: {
  scope: rginfra
  name: 'module-${storage.name}'
  params: {
    kind: storage.kind
    location: location
    name: storage.name
    sku: storage.sku
    fileShares: storage.fileShares
    containers: storage.containers
    networkAcls: storage.networkAcls
    policyId: rsv.outputs.filesharepolicyid
    rsvName: rsv.outputs.rsvname
  }
}]

module aa 'aa.bicep' = {
  scope: rginfra
  name: 'module-${affix}-aa01'
  params: {
    location: location
    name: 'aa-${affix}-01'
    locatonalt: param.locationAlt
  }
}
