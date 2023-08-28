param name string
param location string
param tags object = resourceGroup().tags
@allowed([ 'Allow', 'Deny' ])
param defaultAction string
param virtualNetworkRules array = []

resource kv 'Microsoft.KeyVault/vaults@2023-02-01' = {
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
    networkAcls: {
      defaultAction: defaultAction
      bypass: 'AzureServices'
      virtualNetworkRules: virtualNetworkRules
    }
  }
}

output name string = kv.name
