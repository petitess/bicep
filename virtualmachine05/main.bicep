targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var env = toLower(param.tags.Environment)

resource rgInfra 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  location: param.location
  tags: param.tags
  name: 'rg-${affix}-01'
}

module vnet01 'vnet.bicep' = {
  scope: rgInfra
  name: 'module-${affix}-vnet01'
  params: {
    addressPrefixes: param.vnet01.addressPrefixes
    dnsServers: param.vnet01.dnsServers
    location: rgInfra.location
    name: 'vnet-${env}-01'
    natGateway: param.vnet01.natGateway
    peerings: param.vnet01.peerings
    subnets: param.vnet01.subnets
  }
}

resource rgGal 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  location: param.location
  tags: param.tags
  name: 'rg-gal-${env}-01'
}

module gal 'gal.bicep' = {
  scope: rgGal
  name: 'module-${env}-gallery'
  params: {
    location: param.location
    name: 'gal${env}01'
    param: param
  }
}

resource rgVmavd 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: toLower('rg-vmavd${env}01')
  location: param.location
  tags: {
    Application: 'AVD'
    Environment: param.tags.Environment
  }
}

module vmavd 'vmavd.bicep' = [for (vm, i) in range(0, param.avd.avdCount): if (param.avd.sysprepReady) {
  scope: rgVmavd
  name: 'module-vmavd${vm + 1}'
  params: {
    adminPass: '12345678.abc'
    adminUsername: 'azadmin'
    imageReference: gal.outputs.imageVersion
    location: param.location
    name: toLower('vmavd${env}${vm + 1}')
    osDiskSizeGB: param.avd.osDiskSizeGB
    plan: {}
    tags: param.tags
    vmSize: param.avd.vmSize
    vnetName: vnet01.outputs.name
    vnetRg: rgInfra.name
    subnetName: param.avd.subnetName
    privateIPAddress: '${param.avd.privateIPAddress}${vm + 10}'
  }
}]
