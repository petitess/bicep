targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var env = toLower(param.tags.Environment)
var availabilitysets = [
  'vmadc${env}01'
]

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
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

resource rgavail 'Microsoft.Resources/resourceGroups@2022-09-01' = [for rg in availabilitysets: {
  name: 'rg-${rg}'
  location: param.location
  tags: param.tags
}]

module avail 'avail.bicep' = [for (avail, i) in availabilitysets: {
  scope: rgavail[i]
  name: 'module-vmavail'
  params: {
    location: param.location
    name: 'avail-${avail}'
  }
}]

module lb 'lb.bicep' = {
  scope: resourceGroup('rg-vmadc${env}01')
  dependsOn: [
    rgavail
  ]
  name: 'module-${affix}-lb01'
  params: {
    location: param.location
    name: 'lb-adc-${env}-01'
  }
}

module vmadc 'vmadc.bicep' = [for (vmadc, i) in param.vmadc: {
  scope: rgavail[0]
  name: 'module-${vmadc.name}-vm'
  params: {
    adminPassword: '12345678.abc'
    adminUsername: 'azadmin'
    availId: resourceId(subscription().subscriptionId, rgavail[0].name, 'Microsoft.Compute/availabilitySets', 'avail-${availabilitysets[0]}')
    dataDisks: vmadc.dataDisks
    imageReference: vmadc.imageReference
    location: param.location
    name: vmadc.name
    networkInterfaces: vmadc.networkInterfaces
    osDiskSizeGB: vmadc.osDiskSizeGB
    plan: vmadc.plan
    tags: union(rgavail[0].tags, vmadc.tags)
    vmSize: vmadc.vmSize
    vnetname: vnet.outputs.name
    vnetrg: rg.name
    loadBalancerBackendAddressPoolId: lb.outputs.poolid
  }
}]
