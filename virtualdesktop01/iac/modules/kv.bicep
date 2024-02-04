param name string
param location string
param tags object = resourceGroup().tags
param defaultAction 'Allow' | 'Deny'
param allowedIPs array = []
param workspaceId string

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enabledForTemplateDeployment: true
    enablePurgeProtection: true
    networkAcls: {
      defaultAction: defaultAction
      bypass: 'AzureServices'
      ipRules: [for ip in allowedIPs: {
        value: ip
      }]
    }
  }
}

resource diag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-kv'
  scope: kv
  properties: {
    workspaceId: workspaceId
    logs: [for c in items({ AuditEvent: true, AzurePolicyEvaluationDetails: true }): {
      category: c.key
      enabled: c.value
    }]
  }
}

output name string = kv.name
