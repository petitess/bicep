param location string
param name string
param sku 'Basic' | 'Standard' | 'Premium'
param tags object = resourceGroup().tags
param subscriptions_topics { *: string }?
param dnsRg string
param ipAddress string
param snetPepId string
param queues string[] 
param allowIPs string[]
param rbac {
  role: ('Azure Service Bus Data Owner' | 'Contributor')
  principalId: string
  principalType: ('Device' | 'ForeignGroup' | 'Group' | 'ServicePrincipal' | 'User')?
}[] = []
var subscriptions = map(items(subscriptions_topics), f => f.value)

var rolesList = {
  'Azure Service Bus Data Owner': '090c5cfd-751d-490a-894a-3ce6f1109419'
  Contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
}
resource sb 'Microsoft.ServiceBus/namespaces@2025-05-01-preview' = {
  name: name
  tags: tags
  location: location
  sku: {
    name: sku
  }
}

resource sbt 'Microsoft.ServiceBus/namespaces/topics@2025-05-01-preview' = [
  for t in union(subscriptions, subscriptions): {
    name: t
    parent: sb
    properties: {
      defaultMessageTimeToLive: 'P30D'
    }
  }
]

resource sbta 'Microsoft.ServiceBus/namespaces/topics/authorizationRules@2025-05-01-preview' = [
  for (t, i) in union(subscriptions, subscriptions): {
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
  for t in items(subscriptions_topics): if (t.key != '') {
    name: '${sb.name}/${t.value}/${t.key}'
    dependsOn: [
      sbt
    ]
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
    defaultAction: 'Deny'
    publicNetworkAccess: 'Enabled'
    trustedServiceAccessEnabled: true
    ipRules: [for ip in allowIPs: {
      action: 'Allow'
      ipMask: ip
    }]
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
