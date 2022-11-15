targetScope = 'resourceGroup'

param env string
param location string

var tags = resourceGroup().tags

resource bus 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: 'bus-${env}-01'
  location: location
  tags: tags
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
    disableLocalAuth: false
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    zoneRedundant: false
  }
}

resource authrule1 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2022-01-01-preview' = {
  name: 'auth-${env}-01'
  parent: bus
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}

resource netset 'Microsoft.ServiceBus/namespaces/networkRuleSets@2022-01-01-preview' = {
  name: 'default'
  parent: bus
  properties: {
    defaultAction: 'Allow'
    publicNetworkAccess: 'Enabled'
  }
}

resource queue1 'Microsoft.ServiceBus/namespaces/queues@2022-01-01-preview' = {
  name: 'sbq-log'
  parent: bus
  properties: {
    deadLetteringOnMessageExpiration: false
    defaultMessageTimeToLive: 'P14D'
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    enableBatchedOperations: true
    enableExpress: false
    enablePartitioning: false
    lockDuration: 'PT30S'
    maxDeliveryCount: 10
    maxMessageSizeInKilobytes: 256
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    requiresSession: false
    status: 'Active'
  }
}

resource queue2 'Microsoft.ServiceBus/namespaces/queues@2022-01-01-preview' = {
  name: 'sbq-user'
  parent: bus
  properties: {
    deadLetteringOnMessageExpiration: false
    defaultMessageTimeToLive: 'P14D'
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    enableBatchedOperations: true
    enableExpress: false
    enablePartitioning: false
    lockDuration: 'PT30S'
    maxDeliveryCount: 10
    maxMessageSizeInKilobytes: 256
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    requiresSession: false
    status: 'Active'
  }
}
