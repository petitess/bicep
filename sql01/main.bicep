targetScope = 'subscription'

param tags object
param env string
param timestamp int = dateTimeToEpoch(utcNow())
param location string = deployment().location
param vnet object
param sqls {
  name: string
  adminGroupName: string
  adminGroupObjectId: string
  azureADOnlyAuthentication: bool
  privateIp: string?
  publicNetworkAccess: 'Disabled' | 'Enabled' | 'SecuredByPerimeter' 
  allowedIPs: { *: string }?
  identity: 'None' | 'SystemAssigned' | 'SystemAssigned,UserAssigned' | 'UserAssigned'
  databases: {
    name: string
    collation: 'Finnish_Swedish_CI_AS'
    zoneRedundant: bool
    sku: {
      name: 'GP_Gen5_2' | 'BC_Gen5_2' | 'Basic' | 'Standard' | 'Premium'
    }
  }[]?
  jobAgents: {
    name: string
    dbName: string
    alert: bool
    identity: bool
    sku: {
      name: 'JA100' | 'JA200' | 'JA400' | 'JA800'
      capacity: int
    }
  }[]?
  elasticPools: {
    name: string
    sku: {
      name: 'GP_Gen5' | 'HS_Gen5' | 'BC_Gen5' | 'BasicPool' | 'StandardPool' | 'PremiumPool'
    }
  }[]?
}[]

var unique = take(uniqueString(subscription().subscriptionId), 3)
var prefix = toLower('${unique}-${env}')
var domains = [
  'privatelink${environment().suffixes.sqlServerHostname}'
]
func name(res string, instance string) string => '${res}-${prefix}-${instance}'

resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: name('rg-vnet', '01')
  location: location
  tags: tags
}

resource rgsql 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: name('rg-sql', '01')
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

module sqlM 'sql.bicep' = [
  for sql in sqls: {
    scope: rgsql
    name: '${sql.name}_${timestamp}'
    params: {
      name: sql.name
      location: location
      tags: tags
      publicNetworkAccess: sql.publicNetworkAccess
      identity: sql.identity
      allowedIPs: sql.?allowedIPs
      adminGroupName: sql.adminGroupName
      adminGroupObjectId: sql.adminGroupObjectId
      password: '123456789.abcd'
      snetId: resourceId(
        subscription().subscriptionId,
        rg.name,
        'Microsoft.Network/virtualNetworks/subnets',
        vnetM.outputs.name,
        'snet-pep'
      )
      pdnszId: resourceId(
        subscription().subscriptionId,
        rg.name,
        'Microsoft.Network/privateDnsZones',
        'privatelink${environment().suffixes.sqlServerHostname}'
      )
      username: 'azadmin'
      azureADOnlyAuthentication: sql.azureADOnlyAuthentication
      databases: sql.?databases
      jobAgents: sql.?jobAgents
      privateIp: sql.?privateIp
      elasticPools: sql.?elasticPools
    }
  }
]

