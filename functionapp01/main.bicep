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

module rsv 'rsv.bicep' = {
  scope: rginfra
  name: 'module-${affix}-rsv01'
  params: {
    location: location
    name: 'rsv-${affix}-01'
  }
}

resource rgst 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-st-${affix}-01'
  tags: param.tags
  location: location
}

module st01 'st.bicep' = [for storage in param.st: {
  scope: rgst
  name: 'module-${storage.name}-01'
  params: {
    kind: storage.kind
    location: location
    name: storage.name
    sku: storage.sku
    fileShares: storage.fileShares
    containers: storage.containers
    networkAcls: storage.networkAcls
  }
}]

resource rgfunc 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-func-${affix}-01'
  tags: param.tags
  location: location
}

module logic 'func.bicep' = {
  scope: rgfunc
  name: 'module-${affix}-func01'
  params: {
    location: location
    name: 'func${affix}01'
  }
}
