targetScope = 'subscription'

param tags object
param env string
param timestamp int = dateTimeToEpoch(utcNow())
param location string = deployment().location
param vnet object
param keyVaults {
  name: string
  rgName: string
  publicNetworkAccess: 'Allow' | 'Deny'
  allowIps: string[]
  ipAddress: string
  enablePurgeProtection: bool
}[]

var prefix = toLower('sys-${env}')
var domains = [
  'privatelink.vaultcore.azure.net'
  'privatelink.azure-api.net'
]
var snet = toObject(vnetE.properties.subnets, subnet => subnet.name)
var ip = '1.1.118.1'

func name(res string, instance string) string => '${res}-${prefix}-${instance}'

resource vnetE 'Microsoft.Network/virtualNetworks@2025-05-01' existing = {
  name: name('vnet', '01')
  scope: resourceGroup(name('rg-vnet', '01'))
  dependsOn: [
    vnetM
    rg
  ]
}

resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: name('rg-vnet', '01')
  location: location
  tags: tags
}

module vnetM 'vnet.bicep' = {
  scope: rg
  params: {
    addressPrefixes: vnet.addressPrefixes
    name: name('vnet', '01')
    location: location
    subnets: vnet.subnets
    dnsServers: []
  }
}

module pdnszM 'pdnsz.bicep' = [
  for (domain, i) in domains: {
    name: 'pdnsz-${split(domain, '.')[1]}'
    scope: rg
    params: {
      name: domain
      vnetName: vnetM.outputs.name
      vnetId: vnetM.outputs.id
    }
  }
]

module kvM 'kv.bicep' = [
  for kv in keyVaults: {
    scope: resourceGroup(kv.rgName)
    params: {
      name: kv.name
      location: location
      allowIps: kv.allowIps
      publicNetworkAccess: kv.publicNetworkAccess
      dnsRg: rg.name
      ipAddress: kv.ipAddress
      enablePurgeProtection: kv.enablePurgeProtection
      snetEndpoint: snet['snet-pep'].id
    }
  }
]

module domainM 'domain.se.bicep' = {
  name: 'abcd.se'
  scope: rg
  params: {
    domain: 'abcd.se'
  }
}
