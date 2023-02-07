targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')

resource rginfra 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  location: param.location
  tags: param.tags
  name: 'rg-${affix}-02'
}

module vnet 'vnet.bicep' = {
  scope: rginfra
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

module log 'log.bicep' = {
  name: 'module-${affix}-log'
  scope: rginfra
  params: {
    name: 'log-${affix}-01'
    location: param.location
    sku: param.log.sku
    retentionInDays: param.log.retention
    solutions: param.log.solutions
    events: param.log.events
  }
}

module pdnsz 'pdnsz.bicep' = {
  scope: rginfra
  name: 'module-${affix}-pdnsz'
  params: {
    vnet: vnet.outputs.id
  }
}

module pe 'pe.bicep' = {
  scope: rginfra
  name: 'module-${affix}-pe'
  params: {
    agentsvcdns: pdnsz.outputs.agentsvc
    blobdns: pdnsz.outputs.blob
    location: param.location
    monitordns: pdnsz.outputs.monitor
    odsdns: pdnsz.outputs.ods
    omsdns: pdnsz.outputs.oms
    plname: log.outputs.plname
    rgpename: rginfra.name
    subnetname: param.vnet.subnets[3].name
    vnetname: vnet.outputs.name
  }
}


