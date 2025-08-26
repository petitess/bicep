param name string
param snetId string
param pdnszId string

resource ai 'Microsoft.CognitiveServices/accounts@2025-06-01' = {
  name: name
  location: resourceGroup().location
  sku: {
    name: 'S0'
  }
  kind: 'OpenAI'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    customSubDomainName: name
    apiProperties: {
      qpsQuota: 20
      qpsQuotaPeriod: 'PT1H'
      maxTokensPerMinute: 1000000
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

resource pep 'Microsoft.Network/privateEndpoints@2024-07-01' = {
  name: 'pep-${name}'
  location: resourceGroup().location
  properties: {
    customNetworkInterfaceName: 'nic-pep-${name}'
    privateLinkServiceConnections: [
      {
        name: 'pl-connection'
        properties: {
          privateLinkServiceId: ai.id
          groupIds: [
            'account'
          ]
        }
      }
    ]
    subnet: {
      id: snetId
    }
  }
}

resource dns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-07-01' = {
  name: 'default'
  parent: pep
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-openai-azure-com'
        properties: {
          privateDnsZoneId: pdnszId
        }
      }
    ]
  }
}

resource defender 'Microsoft.CognitiveServices/accounts/defenderForAISettings@2025-06-01' = {
  parent: ai
  name: 'Default'
  properties: {
    state: 'Disabled'
  }
}

resource log 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: 'log-${name}'
  location: resourceGroup().location
  properties: {
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource diag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-ai'
  scope: ai
  properties: {
    workspaceId: log.id
    logs: [
      {
        category: 'Audit'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
      {
        category: 'RequestResponse'
        enabled: true
      }
      {
        category: 'AzureOpenAIRequestUsage'
        enabled: true
      }
      {
        category: 'Trace'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        timeGrain: 'PT1M'
      }
    ]
  }
}

output id string = ai.id
