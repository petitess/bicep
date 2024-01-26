param name string
param location string
param tags object = resourceGroup().tags
param defaultAction 'Allow' | 'Deny'
param virtualNetworkRules { id: string }[] = []
param enableRbac bool
param accessPolicies { tenantId: string, objectId: string, permissions: object }[] = []
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
    enableRbacAuthorization: enableRbac
    enabledForTemplateDeployment: true
    networkAcls: {
      defaultAction: defaultAction
      bypass: 'AzureServices'
      virtualNetworkRules: virtualNetworkRules
    }
    accessPolicies: !enableRbac ? accessPolicies : []
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
