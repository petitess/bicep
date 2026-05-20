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
  identity: bool
  alert: bool
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
param jobRbac {
  jobAgentName: string
  jobName: string
  principalId: string
  principalType: string?
  roleDefinitionId: string?
}[] = []
param targetGroups {
  jobAgentName: string
  name: string
}[] = []
param jobs {
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
}[] = []

@description('steps transformed to an array of objects')
var stepsObject object = toObject(jobs, entry => entry.name, entry => {
  subscriptions: toObject(entry.steps, subEntry => subEntry.name, subEntry => {
    name: subEntry.name
    type: subEntry.type
    source: subEntry.source
    steps: entry.steps
    value: subEntry.value
    jobAgentName: entry.jobAgentName
    targetGroup: subEntry.targetGroup
  })
})
var jobsArray array = [
  for i in items(stepsObject): reduce(
    items(i.value.subscriptions),
    {},
    (acc, curr) =>
      union(acc, {
        '${i.key}/${curr.key}': {
          name: curr.value.name
          type: curr.value.type
          source: curr.value.source
          value: curr.value.value
          jobAgentName: curr.value.jobAgentName
          targetGroup: curr.value.targetGroup
        }
      })
  )
]
var stepsArray array = items(reduce(jobsArray, {}, (acc, curr) => union(acc, curr)))

var identityJobAgents array = map(jobAgents, ja => ja.identity)
output yyy bool = contains(identityJobAgents, true)

resource id 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' = if (identity == 'SystemAssigned,UserAssigned' || identity == 'UserAssigned' || contains(
  identityJobAgents,
  true
)) {
  name: 'id-${name}'
  location: location
}

resource sql 'Microsoft.Sql/servers@2025-01-01' = {
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

resource fw 'Microsoft.Sql/servers/firewallRules@2025-01-01' = [
  for a in items(allowedIPs == null ? {} : allowedIPs): {
    name: a.key
    parent: sql
    properties: {
      endIpAddress: a.value
      startIpAddress: a.value
    }
  }
]

resource pep 'Microsoft.Network/privateEndpoints@2025-05-01' = {
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

resource dns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2025-05-01' = {
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

resource db 'Microsoft.Sql/servers/databases@2025-01-01' = [
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

resource jaR 'Microsoft.Sql/servers/jobAgents@2025-01-01' = [
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

resource targetGroup 'Microsoft.Sql/servers/jobAgents/targetGroups@2025-01-01' = [
  for (ja, i) in jobAgents: {
    parent: jaR[i]
    name: 'tg-default'
    properties: {
      members: []
    }
  }
]

resource targetGroupsR 'Microsoft.Sql/servers/jobAgents/targetGroups@2025-01-01' = [
  for (t, i) in targetGroups: {
    name: '${name}/${t.jobAgentName}/${t.name}'
    properties: {
      members: []
    }
  }
]

resource jobsR 'Microsoft.Sql/servers/jobAgents/jobs@2025-01-01' = [
  for (j, i) in jobs: {
    name: '${name}/${j.jobAgentName}/${j.name}'
    properties: {
      description: j.?description
      schedule: {
        type: j.type
        interval: j.?interval ?? 'PT24H'
        startTime: j.?startTime ?? '0001-01-01T00:00:00Z'
        endTime: j.?endTime ?? '9999-12-31T11:59:59Z'
        enabled: j.enabled
      }
    }
  }
]

resource steps 'Microsoft.Sql/servers/jobAgents/jobs/steps@2025-01-01' = [
  for (s, i) in stepsArray: {
    name: '${name}/${s.value.jobAgentName}/${s.key}'
    properties: {
      targetGroup: resourceId(
        'Microsoft.Sql/servers/jobAgents/targetGroups',
        sql.name,
        s.value.jobAgentName,
        s.value.targetGroup
      )
      action: {
        type: s.value.type
        source: s.value.source
        value: s.value.value
      }
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
resource pepR 'Microsoft.Sql/servers/jobAgents/privateEndpoints@2025-01-01' = [
  for (ja, i) in jobAgents: if (false) {
    name: 'pep-${ja.name}'
    parent: jaR[i]
    properties: {
      targetServerAzureResourceId: sql.id
    }
  }
]

resource rbacAgentReader 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (r, i) in jobRbac: {
    name: guid(sql.id, r.jobAgentName, r.jobName, r.principalId, 'reader', jaR[0].id)
    // scope: jaR[i]
    properties: {
      roleDefinitionId: subscriptionResourceId(
        'Microsoft.Authorization/roleDefinitions',
        'acdd72a7-3385-48ef-bd42-f606fba81ae7'
      )
      principalId: r.principalId
      principalType: r.?principalType ?? 'ServicePrincipal'
    }
  }
]

resource customRoleExecuteJob 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid(sql.id, 'CustomRole', 'JobAgentExecutor')
  properties: {
    roleName: 'Job Agent Executor'
    assignableScopes: [
      resourceGroup().id
    ]
    description: 'Can monitor and execute jobs on the assigned jobs.'
    type: 'CustomRole'
    permissions: [
      {
        actions: [
          'Microsoft.Sql/servers/jobAgents/read'
          'Microsoft.Sql/servers/jobAgents/jobs/*'
        ]
        notActions: []
        dataActions: []
        notDataActions: []
      }
    ]
  }
}

resource rbacJob 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (r, i) in jobRbac: {
    name: guid(sql.id, r.jobAgentName, r.jobName, r.principalId, customRoleExecuteJob.id)
    scope: jobsR[i]
    properties: {
      roleDefinitionId: customRoleExecuteJob.id
      principalId: r.principalId
      principalType: r.?principalType ?? 'ServicePrincipal'
    }
  }
]

#disable-next-line use-recent-api-versions
resource alert 'Microsoft.Insights/metricAlerts@2024-03-01-preview' = [
  for (a, i) in jobAgents: if (a.alert) {
    name: toLower('${a.name}-failed')
    location: 'global'
    tags: tags
    properties: {
      severity: 2
      enabled: true
      scopes: [
        jaR[i].id
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
      actions: []
    }
  }
]
