targetScope = 'subscription'

param env string
param location string
param tags object
param vnet object
param pdnsz object

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  location: location
  tags: tags
  name: 'rg-vnet-${env}-01'
}

resource rgDns 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  location: location
  tags: tags
  name: 'rg-dns-${env}-01'
}

resource rgRsv 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  location: location
  tags: tags
  name: 'rg-rsv-${env}-01'
}

module vnetM 'vnet.bicep' = {
  scope: rg
  name: 'vnet'
  params: {
    addressPrefixes: vnet.addressPrefixes
    env: env
    location: location
    subnets: vnet.subnets
  }
}

module pdnszM 'pdnsz.bicep' = [for (domain, i) in pdnsz.domains: {
  name: domain
  scope: rgDns
  params: {
    name: domain
    vnetName: vnetM.outputs.name
    vnetId: vnetM.outputs.id
  }
}]

module rsv 'rsv.bicep' = {
  scope: rgRsv
  name: 'rsv'
  params: {
    dnsRgName: rgDns.name
    location: location
    name: 'rsv-${env}-01'
    snetId: vnetM.outputs.snet['snet-pep'].id
    timeZone: 'W. Europe Standard Time'
    retentionTimes: [
      '22:30:00'
    ]
    scheduleRunTimes: [
      '22:30:00'
    ]
    sku: {
      name: 'RS0'
      tier: 'Standard'
    }
    
  }
}
