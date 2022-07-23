targetScope = 'resourceGroup'

param location string
param kvname string

resource kv01 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: kvname
  tags: resourceGroup().tags
  location: location
  properties: {
    sku: {
      family:  'A'
      name:  'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enabledForDeployment: true
    enabledForTemplateDeployment:true 
  }
}

output kvname string = kv01.name
