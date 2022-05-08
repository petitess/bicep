param name string
param location string

var tags = resourceGroup().tags
var tenantId = subscription().tenantId
var sku = 'standard'
var enableSoftDelete = true
var softDeleteRetentionInDays = 90
var enabledForDeployment = false
var enabledForTemplateDeployment = true
var enabledForDiskEncryption = true
var enableRbacAuthorization = true

resource kv 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: sku
    }
    tenantId: tenantId
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enabledForDeployment: enabledForDeployment
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enableRbacAuthorization: enableRbacAuthorization
  }
}

resource key 'Microsoft.KeyVault/vaults/keys@2021-11-01-preview' = {
  parent: kv
  name: 'keyEncryptionKey'
  properties: {
    kty: 'RSA'
    keySize: 2048
  }
}

output kvId string = kv.id
output kvName string = kv.name
output kvUrl string = kv.properties.vaultUri
output keyUrl string = key.properties.keyUriWithVersion
