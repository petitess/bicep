param name string
param location string
param tags object
@secure()
param username string
@secure()
param password string
param adminGroupName string
param adminGroupObjectId string
param snetId string
param azureADOnlyAuthentication bool
param publicNetworkAccess 'Disabled' | 'Enabled' | 'SecuredByPerimeter'
param allowedIPs { *: string }?
param identity 'None' | 'SystemAssigned' | 'SystemAssigned,UserAssigned' | 'UserAssigned'
param databases {
  name: string
  collation: string
  maxSizeBytes: int?
  zoneRedundant: bool
  sku: {
    name: 'GP_Gen5_2' | 'BC_Gen5_2' | 'Basic' | 'Standard' | 'Premium'
  }
}[] = []
param jobAgents {
  name: string
  dbName: string
  alert: bool
  identity: bool
  sku: {
    name: 'JA100' | 'JA200' | 'JA400' | 'JA800'
    capacity: int
  }
}[] = []
param elasticPools {
  name: string
  sku: {
    name: 'GP_Gen5' | 'HS_Gen5' | 'BC_Gen5' | 'BasicPool' | 'StandardPool' | 'PremiumPool'
  }
}[] = []
param privateIp string = ''
param pdnszId string

var identityJobAgents array = map(jobAgents, ja => ja.identity)
output yyy bool = contains(identityJobAgents, true)

resource id 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' = if (identity == 'SystemAssigned,UserAssigned' || identity == 'UserAssigned' || contains(
  identityJobAgents,
  true
)) {
  name: 'id-${name}'
  location: location
}

resource sql 'Microsoft.Sql/servers@2024-11-01-preview' = {
  name: name
  location: location
  tags: tags
  identity: identity == 'SystemAssigned,UserAssigned'
    ? {
        type: 'SystemAssigned,UserAssigned'
        userAssignedIdentities: {
          '${id.id}': {}
        }
      }
    : identity == 'SystemAssigned'
        ? {
            type: 'SystemAssigned'
          }
        : identity == 'UserAssigned'
            ? {
                type: 'UserAssigned'
                userAssignedIdentities: {
                  '${id.id}': {}
                }
              }
            : null
  properties: {
    administratorLogin: azureADOnlyAuthentication ? null : username
    administratorLoginPassword: azureADOnlyAuthentication ? null : password
    minimalTlsVersion: '1.2'
    publicNetworkAccess: publicNetworkAccess
    administrators: {
      administratorType: 'ActiveDirectory'
      login: adminGroupName
      azureADOnlyAuthentication: azureADOnlyAuthentication
      sid: adminGroupObjectId
      principalType: 'Group'
      tenantId: tenant().tenantId
    }
  }

  resource entraOnly 'azureADOnlyAuthentications' = {
    name: 'Default'
    properties: {
      azureADOnlyAuthentication: azureADOnlyAuthentication
    }
  }
}

resource fw 'Microsoft.Sql/servers/firewallRules@2024-11-01-preview' = [
  for a in items(allowedIPs == null ? {} : allowedIPs): {
    name: a.key
    parent: sql
    properties: {
      endIpAddress: a.value
      startIpAddress: a.value
    }
  }
]

resource pep 'Microsoft.Network/privateEndpoints@2024-10-01' = {
  name: 'pep-${name}'
  location: location
  tags: tags
  properties: {
    subnet: {
      id: snetId
    }
    customNetworkInterfaceName: 'nic-${name}'
    privateLinkServiceConnections: [
      {
        name: 'config'
        properties: {
          privateLinkServiceId: sql.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
    ipConfigurations: !empty(privateIp)
      ? [
          {
            name: 'config'
            properties: {
              privateIPAddress: privateIp
              groupId: 'sqlServer'
              memberName: 'sqlServer'
            }
          }
        ]
      : []
  }
}

resource dns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-10-01' = {
  name: 'default'
  parent: pep
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-database-windows-net'
        properties: {
          privateDnsZoneId: pdnszId
        }
      }
    ]
  }
}

resource db 'Microsoft.Sql/servers/databases@2024-05-01-preview' = [
  for d in databases: {
    parent: sql
    name: d.name
    location: location
    sku: d.sku
    properties: {
      collation: d.collation
      zoneRedundant: false
      readScale: 'Disabled'
      requestedBackupStorageRedundancy: 'Local'
      isLedgerOn: false
      availabilityZone: 'NoPreference'
      licenseType: 'LicenseIncluded'
    }
  }
]

resource jaR 'Microsoft.Sql/servers/jobAgents@2024-11-01-preview' = [
  for (ja, i) in jobAgents: {
    parent: sql
    dependsOn: [
      db
    ]
    identity: ja.identity
      ? {
          type: 'UserAssigned'
          userAssignedIdentities: {
            '${id.id}': {}
          }
        }
      : null
    sku: ja.sku
    name: ja.name
    location: location
    properties: {
      databaseId: resourceId('Microsoft.Sql/servers/databases', sql.name, ja.dbName)
    }
  }
]

resource e 'Microsoft.Sql/servers/elasticPools@2024-11-01-preview' = [
  for p in elasticPools: {
    name: p.name
    parent: sql
    location: location
    sku: p.sku
    properties: {
      autoPauseDelay: -1
      availabilityZone: 'NoPreference'
      highAvailabilityReplicaCount: 0
      licenseType: 'LicenseIncluded'
      zoneRedundant: false
    }
  }
]
//Must approve manually
resource sdf 'Microsoft.Sql/servers/jobAgents/privateEndpoints@2024-11-01-preview' = [
  for (ja, i) in jobAgents: if(false) {
    name: 'pep-${ja.name}'
    parent: jaR[i]
    properties: {
      targetServerAzureResourceId: sql.id
    }
  }
]

resource alert 'Microsoft.Insights/metricAlerts@2024-03-01-preview' = [
  for (a, i) in jobAgents: if (a.alert) {
    name: toLower('${a.name}-failed')
    location: 'global'
    tags: tags
    properties: {
      severity: 2
      enabled: true
      scopes: [
        ja[i].id
      ]
      evaluationFrequency: 'PT1H'
      windowSize: 'PT1H'
      criteria: {
        allOf: [
          {
            threshold: json('0')
            name: 'Metric1'
            metricNamespace: 'Microsoft.Sql/servers/jobAgents'
            metricName: 'elastic_jobs_failed'
            operator: 'GreaterThan'
            timeAggregation: 'Count'
            skipMetricValidation: false
            criterionType: 'StaticThresholdCriterion'
          }
        ]
        'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      }
      autoMitigate: false
      targetResourceType: 'Microsoft.Sql/servers/jobAgents'
      targetResourceRegion: 'westeurope'
      actions: [
        {
          actionGroupId: actionGroupId
        }
      ]
    }
  }
]