param name string
param location string
param tags object = resourceGroup().tags
param sku string
param enabledForDeployment bool
param enabledForTemplateDeployment bool
param enabledForDiskEncryption bool
param enableRbacAuthorization bool

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: sku
    }
    tenantId: subscription().tenantId
    enabledForDeployment: enabledForDeployment
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enableRbacAuthorization: enableRbacAuthorization
  }
}

output id string = kv.id
output name string = kv.name
output kvUrl string = kv.properties.vaultUri
