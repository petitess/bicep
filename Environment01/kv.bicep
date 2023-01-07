targetScope = 'resourceGroup'

param location string
param kvname string

var sku = 'standard'
var tenantid = subscription().tenantId
var tags = resourceGroup().tags
var secretname = 'adminUsername'
var value = 'azadmin'

resource kv01 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: kvname
  tags: tags
  location: location
  properties: {
    sku: {
      family:  'A'
      name: sku
    }
    tenantId: tenantid
    enableRbacAuthorization: true
    enabledForDeployment: true
    enabledForTemplateDeployment:true 
  }
}

resource kvsecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: secretname
  parent: kv01
  tags: tags
  properties: {
    value: value
  }
}

output name string = kv01.name
output username string = kvsecret.name
