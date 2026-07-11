targetScope = 'subscription'
extension 'br:mcr.microsoft.com/bicep/extensions/microsoftgraph/v1.0:1.0.0'
param tags object
param env string
param timestamp int = dateTimeToEpoch(utcNow())
param location string = deployment().location
param vnet object
param sqls {
  name: string
  // adminGroupName: string
  // adminGroupObjectId: string
  azureADOnlyAuthentication: bool
  privateIp: string?
  publicNetworkAccess: 'Disabled' | 'Enabled' | 'SecuredByPerimeter'
  allowedIPs: { *: string }?
  identity: 'None' | 'SystemAssigned' | 'SystemAssigned,UserAssigned' | 'UserAssigned'
  databases: {
    name: string
    collation: 'Finnish_Swedish_CI_AS'
    zoneRedundant: bool
    @description('Name of an elastic pool. Sku should be: ElasticPool')
    elasticPoolName: string?
    sku: {
      name: 'GP_Gen5_2' | 'BC_Gen5_2' | 'Basic' | 'Standard' | 'Premium' | 'ElasticPool'
    }
  }[]?
  jobAgents: {
    name: string
    dbName: string
    identity: bool
    alert: bool
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
  jobRbac: {
    jobAgentName: string
    jobName: string
    principalId: string
    principalType: string?
    roleDefinitionId: string?
  }[]?
  jobs: {
    name: string
    description: string?
    type: 'Recurring' | 'Once'
    interval: string?
    startTime: string?
    endTime: string?
    enabled: true
    jobAgentName: string
    steps: {
      name: string
      type: 'TSql'
      source: 'Inline' | 'FilePath'
      value: string
      targetGroup: string
    }[]
  }[]?
  targetGroups: {
    jobAgentName: string
    name: string
  }[]?
}[]
param managedIdentities {
  name: string
  sqlGroup: string?
  rgName: string
  federatedIdentityCredentials: {
    name: string
    subject: string
    issuer: string?
  }[]?
}[] = []

var unique = take(uniqueString(subscription().subscriptionId), 3)
var prefix = toLower('${unique}-${env}')
var domains = [
  // 'privatelink${environment().suffixes.sqlServerHostname}'
]
func name(res string, instance string) string => '${res}-${prefix}-${instance}'

resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: name('rg-vnet', '01')
  location: location
  tags: tags
}

resource rgSql 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: 'rg-sql-system-${env}-01'
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
  for (sql,i) in sqls: {
    scope: rgSql
    name: '${sql.name}_${timestamp}'
    params: {
      name: sql.name
      location: location
      tags: tags
      publicNetworkAccess: sql.publicNetworkAccess
      identity: sql.identity
      allowedIPs: sql.?allowedIPs
      adminGroupName: sqlGroups[i].displayName
      adminGroupObjectId: sqlGroups[i].id
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
      jobRbac: sql.?jobRbac
      jobs: sql.?jobs
      targetGroups: sql.?targetGroups
    }
  }
]

@description('Group.ReadWrite.All')
resource sqlGroups 'Microsoft.Graph/groups@v1.0' = [
  for (sql, i) in sqls: {
    displayName: toLower('grp-${sql.name}-admin')
    mailEnabled: false
    mailNickname: toLower('grp-${sql.name}-admin')
    securityEnabled: true
    uniqueName: toLower('grp-${sql.name}-admin')
    members: {
      relationships: [
        for (obj, i) in filter(managedIdentities, x => x.?sqlGroup == 'grp-${sql.name}-admin'): reference(
          resourceId(
            subscription().subscriptionId,
            obj.rgName,
            'Microsoft.ManagedIdentity/userAssignedIdentities',
            obj.name
          ),
          '2025-05-31-preview',
          'Full'
        ).properties.principalId
      ]
      // relationships: [
      //   for (obj, i) in filter(union(functionApp, apps), x => x.?sqlGroup == 'grp-az-${sql.name}-admin'): reference(
      //     resourceId(subscription().subscriptionId, obj.rgName, 'Microsoft.Web/sites', obj.name),
      //     '2026-03-15',
      //     'Full'
      //   ).identity.principalId
      // ]
    }
  }
]

module idM 'id.bicep' = [
  for i in managedIdentities: {
    scope: resourceGroup(i.rgName)
    params: {
      name: i.name
      location: location
      federatedIdentityCredentials: i.?federatedIdentityCredentials
    }
  }
]
