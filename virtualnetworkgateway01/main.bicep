targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${affix}-01'
  location: param.location
  tags: param.tags
}

module kv 'kv.bicep' = {
  scope: rg
  name: 'module-kv'
  params: {
    location: param.location
    name: 'kv-comp-${affix}-01'
    sku: param.kv.sku
    enabledForDeployment: param.kv.enabledForDeployment
    enabledForDiskEncryption: param.kv.enabledForDiskEncryption
    enabledForTemplateDeployment: param.kv.enabledForTemplateDeployment
    enableRbacAuthorization: param.kv.enableRbacAuthorization
  }
}

module vnet 'vnet.bicep' = {
  scope: rg
  name: 'module-vnet'
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

module vgw 'vgw.bicep' = {
  scope: rg
  name: 'module-vgw'
  params: {
    param: param
    snetId: vnet.outputs.snet.GatewaySubnet.id
    name: 'vgw-${affix}-01'
  }
}

resource kvExisting 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  scope: resourceGroup(rg.name)
  name: toLower('kv-comp-${affix}-01')
}

module lgw 'vgw-lgw.bicep' = [for vpn in param.vgw.customers: {
  scope: rg
  name: 'module-lgw-${vpn.name}'
  params: {
    gatewayIpAddress: vpn.gatewayIpAddress
    ipsecPolicies: contains(vpn, 'ipsecPolicies') ? vpn.ipsecPolicies : []
    localAddresses: vpn.localAddresses
    name: vpn.name
    param: param
    sharedKey: kvExisting.getSecret('con-${vpn.name}-sc')
    tag: vpn.tag
    vgwId: vgw.outputs.id
  }
}]
