param location string
param name string
param sku 'Basic' | 'Standard' | 'Premium'
param tags object = resourceGroup().tags
param topics {
  name: string
  properties: resourceInput<'Microsoft.ServiceBus/namespaces/topics@2025-05-01-preview'>.properties
  subscriptions: {
    name: string
    properties: resourceInput<'Microsoft.ServiceBus/namespaces/topics/subscriptions@2025-05-01-preview'>.properties
    rules: resourceInput<'Microsoft.ServiceBus/namespaces/topics/subscriptions/rules@2025-05-01-preview'>.properties[]
  }[]
}[]
param dnsRg string
param ipAddress string
param snetPepId string
param logId string
param queues string[]
param allowIPs string[]
param rbac {
  role: ('Azure Service Bus Data Owner' | 'Contributor')
  principalId: string
  principalType: ('Device' | 'ForeignGroup' | 'Group' | 'ServicePrincipal' | 'User')?
}[] = []

var rolesList = {
  'Azure Service Bus Data Owner': '090c5cfd-751d-490a-894a-3ce6f1109419'
  Contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
}
var subscriptionsObject object = toObject(topics, entry => entry.name, entry => {
  subscriptions: toObject(entry.subscriptions, subEntry => subEntry.name, subEntry => {
    properties: subEntry.properties
    name: subEntry.name
    topic: entry.name
    rules: subEntry.rules ?? []
  })
})
var topicArray array = [
  for i in items(subscriptionsObject): reduce(
    items(i.value.subscriptions),
    {},
    (acc, curr) =>
      union(acc, {
        '${i.key}/${curr.key}': {
          properties: curr.value.properties
          name: curr.value.name
          topic: i.key
          rules: curr.value.rules
        }
      })
  )
]
var subscriptionsArray array = items(reduce(topicArray, {}, (acc, curr) => union(acc, curr)))
var rulesObject object = toObject(subscriptionsArray, entry => entry.key, entry => entry.value.rules)
var topicRulesArray array = [
  for (r, i) in items(rulesObject): reduce(
    r.value,
    {},
    (acc, curr) =>
      union(acc, {
        '${r.key}/${curr.filterType}_${i}': curr
      })
  )
]
var rulesArray array = items(reduce(topicRulesArray, {}, (acc, curr) => union(acc, curr)))

resource sb 'Microsoft.ServiceBus/namespaces@2025-05-01-preview' = {
  name: name
  tags: tags
  location: location
  properties: {
    publicNetworkAccess: 'Enabled'
  }
  sku: {
    name: sku
  }
}

resource sbt 'Microsoft.ServiceBus/namespaces/topics@2025-05-01-preview' = [
  for t in topics: {
    name: t.name
    parent: sb
    properties: { ...t.properties }
  }
]

resource sbta 'Microsoft.ServiceBus/namespaces/topics/authorizationRules@2025-05-01-preview' = [
  for (t, i) in topics: {
    name: 'access'
    parent: sbt[i]
    properties: {
      rights: [
        'Listen'
        'Manage'
        'Send'
      ]
    }
  }
]

resource sbtSubs 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2025-05-01-preview' = [
  for (t, i) in subscriptionsArray: {
    name: '${sb.name}/${t.key}'
    dependsOn: [
      sbt
    ]
    properties: t.value.properties
  }
]

resource sbtSubsRules 'Microsoft.ServiceBus/namespaces/topics/subscriptions/rules@2025-05-01-preview' = [
  for (t, i) in rulesArray: {
    name: '${sb.name}/${t.key}'
    dependsOn: [
      sbtSubs
    ]
    properties: t.value
  }
]

resource sbq 'Microsoft.ServiceBus/namespaces/queues@2025-05-01-preview' = [
  for t in queues: {
    name: t
    parent: sb
    properties: {}
  }
]

resource sbqa 'Microsoft.ServiceBus/namespaces/queues/authorizationRules@2025-05-01-preview' = [
  for (t, i) in queues: {
    name: 'access'
    parent: sbq[i]
    properties: {
      rights: [
        'Listen'
        'Manage'
        'Send'
      ]
    }
  }
]

resource network 'Microsoft.ServiceBus/namespaces/networkRuleSets@2025-05-01-preview' = {
  name: 'default'
  parent: sb
  properties: {
    defaultAction: 'Allow'
    publicNetworkAccess: 'Enabled'
    trustedServiceAccessEnabled: true
    ipRules: [
      for ip in allowIPs: {
        action: 'Allow'
        ipMask: ip
      }
    ]
  }
}

resource rbacR 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (r, i) in rbac: if (rbac != []) {
    name: guid(resourceGroup().id, r.principalId, r.role, string(i))
    properties: {
      principalId: r.principalId
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleAssignments', rolesList[r.role])
      principalType: r.?principalType ?? 'ServicePrincipal'
    }
  }
]

resource pep 'Microsoft.Network/privateEndpoints@2024-10-01' = if (sku == 'Premium') {
  name: 'pep-${sb.name}'
  location: location
  tags: tags
  properties: {
    customNetworkInterfaceName: 'nic-${sb.name}'
    subnet: {
      id: snetPepId
    }
    ipConfigurations: ipAddress != ''
      ? [
          {
            name: 'config'
            properties: {
              groupId: 'namespace'
              memberName: 'namespace'
              privateIPAddress: ipAddress
            }
          }
        ]
      : []
    privateLinkServiceConnections: [
      {
        name: 'config'
        properties: {
          privateLinkServiceId: sb.id
          groupIds: [
            'namespace'
          ]
        }
      }
    ]
  }
}

resource pdnszg 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-10-01' = if (sku == 'Premium') {
  name: 'default'
  parent: pep
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'servicebus'
        properties: {
          privateDnsZoneId: resourceId(dnsRg, 'Microsoft.Network/privateDnsZones', 'privatelink.servicebus.windows.net')
        }
      }
    ]
  }
}

resource diag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${sb.name}'
  scope: sb
  properties: {
    workspaceId: logId
    logs: [
      {
        category: 'OperationalLogs'
        enabled: true
      }
      {
        category: 'DiagnosticErrorLogs'
        enabled: true
      }
      {
        category: 'VNetAndIPFilteringLogs'
        enabled: true
      }
      {
        category: 'RuntimeAuditLogs'
        enabled: true
      }
      {
        category: 'ApplicationMetricsLogs'
        enabled: true
      }
      {
        category: 'DataDRLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

output sbSasas string = listKeys(sbta[0].id, '2025-05-01-preview').primaryConnectionString
