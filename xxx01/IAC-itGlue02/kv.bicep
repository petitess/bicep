param name string
param location string
param tags object = resourceGroup().tags

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enabledForDeployment: false
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    enableRbacAuthorization: true
  }
}

resource sec 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'itglue'
  parent: kv
  properties: {
    value: ''
  }
}

output id string = kv.id
output name string = kv.name
output kvUrl string = kv.properties.vaultUri
