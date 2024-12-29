param appName string
param location string
param snetPepId string
param LogId string
param entraGroupName string
param entraGroupSid string
param ipPep string?
param sqlDtu int = 0
param sqlTier string = 'Standard'
param dnsRg string
param dbCount int = 0
param publicNetworkAccess 'Disabled' | 'Enabled'?
param entraOnlyAuthentication bool = true

var tags = resourceGroup().tags

resource sql 'Microsoft.Sql/servers@2024-05-01-preview' = {
  name: 'sql-${appName}'
  location: location
  tags: union(tags, {
    ApplicationTier: 'Backend'
  })
  properties: {
    restrictOutboundNetworkAccess: 'Disabled'
    version: '12.0'
    administrators: {
      azureADOnlyAuthentication: entraOnlyAuthentication
      login: entraGroupName
      sid: entraGroupSid
    }
    publicNetworkAccess: publicNetworkAccess
    minimalTlsVersion: '1.2'
  }
}

resource db 'Microsoft.Sql/servers/databases@2024-05-01-preview' = [
  for (db, i) in range(1, dbCount): {
    name: 'sqldb-${substring(appName, 0, length(appName) - 2)}0${i + 1}'
    location: location
    tags: union(tags, {
      ApplicationTier: 'Backend'
    })
    parent: sql
    sku: {
      name: sqlTier
      tier: sqlTier
      capacity: sqlDtu
    }
    properties: {
      collation: 'Finnish_Swedish_CI_AS'
    }
  }
]

resource masterDb 'Microsoft.Sql/servers/databases@2024-05-01-preview' existing = {
  name: 'master'
  parent: sql
}

resource diagsql 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (false) {
  name: 'diag-${appName}-master'
  dependsOn: [db]
  scope: masterDb
  properties: {
    workspaceId: LogId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'SQLSecurityAuditEvents'
        enabled: true
      }
    ]
  }
}

resource auditsettings 'Microsoft.Sql/servers/auditingSettings@2023-05-01-preview' = {
  name: 'default'
  parent: sql
  properties: {
    auditActionsAndGroups: [
      'BATCH_COMPLETED_GROUP'
      'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
      'FAILED_DATABASE_AUTHENTICATION_GROUP'
    ]
    isAzureMonitorTargetEnabled: true
    state: 'Enabled'
  }
}

resource diagdb 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
  for (item, i) in range(1, dbCount): {
    name: 'diag-sqldb-${appName}'
    scope: db[i]
    properties: {
      workspaceId: LogId
      logAnalyticsDestinationType: 'Dedicated'
      logs: [
        {
          categoryGroup: 'audit'
          enabled: true
        }
      ]
    }
  }
]

resource enc 'Microsoft.Sql/servers/databases/transparentDataEncryption@2024-05-01-preview' = [
  for (item, i) in range(1, dbCount): if (false) {
    name: 'current'
    parent: db[i]
    properties: {
      state: 'Enabled'
    }
  }
]

resource PeSQL 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: 'pep-sql-${appName}'
  location: location
  tags: tags
  properties: {
    customNetworkInterfaceName: 'nic-sql-${appName}'
    subnet: {
      id: snetPepId
    }
    ipConfigurations: [
      {
        name: 'config-${appName}'
        properties: {
          privateIPAddress: ipPep
          groupId: 'sqlServer'
          memberName: 'sqlServer'
        }
      }
    ]
    privateLinkServiceConnections: [
      {
        name: sql.name
        properties: {
          privateLinkServiceId: sql.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
}

resource pdnszSQL 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = {
  name: 'Default'
  parent: PeSQL
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-database-windows-net'
        properties: {
          privateDnsZoneId: resourceId(
            dnsRg,
            'Microsoft.Network/privateDnsZones',
            'privatelink${environment().suffixes.sqlServerHostname}'
          )
        }
      }
    ]
  }
}

resource SQLvulnerabilityAssessment 'Microsoft.Sql/servers/sqlVulnerabilityAssessments@2024-05-01-preview' = if (false) {
  name: 'SQLVulnerabilityAssessments'
  parent: sql
  properties: {
    state: 'Enabled'
  }
}
