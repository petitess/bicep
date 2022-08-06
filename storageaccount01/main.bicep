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
    rsvRg: rginfra.name
  }
}]
