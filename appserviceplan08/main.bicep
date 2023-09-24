targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var env = toLower(param.tags.Environment)

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${affix}-sc-01'
  location: param.location
  tags: param.tags
}

resource rgDns 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-dns-${env}-01'
  location: param.location
  tags: union(param.tags, {
      Application: 'DNS Zones'
    })
}

resource rgApp 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-app-${env}-01'
  location: param.location
  tags: union(param.tags, {
      Application: 'ITglue Integration'
    })
}

module vnet 'vnet.bicep' = {
  scope: rg
  name: 'vnet-${env}'
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

module pdnsz 'pdnsz.bicep' = [for (zone, i) in param.privateZones: {
  name: zone
  scope: rgDns
  params: {
    name: zone
    vnetId: vnet.outputs.id
  }
}]

module app 'app.bicep' = {
  scope: rgApp
  name: 'app-${env}'
  params: {
    name: 'appdeployment01'
    location: param.location
    snetOutboundId: vnet.outputs.snet['snet-outbound-prod-01'].id
    snetPepId: vnet.outputs.snet['snet-pe-prod-01'].id
    rgDns: rgDns.name
  }
}

module sql 'sql.bicep' = {
  scope: rgApp
  name: 'sql-${env}'
  params: {
    location: param.location
    name: 'appdeployment01'
    rgDns: rgDns.name
    snetPepId: vnet.outputs.snet['snet-pe-prod-01'].id
  }
}
