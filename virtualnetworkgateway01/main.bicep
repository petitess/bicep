targetScope = 'subscription'

param param object
var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var affixsub = toLower('${take(subscription().subscriptionId, 7)}-${param.tags.Environment}')

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

module id 'id.bicep' = {
  scope: rg
  name: 'module-${affix}-id01'
  params: {
    location: param.location
    name: 'id-${affix}-01'
  }
}

module rbac 'rbac.bicep' = {
  name: 'module-${affix}-rbac01'
  params: {
    principalId: id.outputs.id
  }
}

module kv 'kv.bicep' = {
  scope: rg
  name: 'module-${affix}-kv01'
  params: {
    kvname: 'kv-${affixsub}-01'
    location: param.location
  }
}

module script 'script.bicep' = {
  scope: rg
  name: 'module-${affix}-script01'
  params: {
    location: param.location
    name: 'script-${affix}-01'
    idId: id.outputs.idid
    idName: id.outputs.idname
    kvName: kv.outputs.kvname
    tags: param.tags
    param: param
  }
}

resource kvexisting 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: 'kv-${affixsub}-01'
  scope: rg
}

module vgw 'vgw.bicep' = {
  scope: rg
  name: 'module-${affix}-vgw'
  params: {
    name: 'vgw-${affix}-01'
    subnetid: vnet.outputs.GatewaySubnetId
    param: param
    lgwname: 'lgw-${affix}-01'
    sharedKey: kvexisting.getSecret(script.outputs.consecret)
  }
}
