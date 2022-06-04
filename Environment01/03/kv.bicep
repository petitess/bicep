targetScope = 'resourceGroup'

param location string
param kvname string
param principalId string

var sku = 'standard'
var tenantid = subscription().tenantId
var tags = resourceGroup().tags
var secretname = 'adminUsername'
var secretvalue = 'azadmin'

resource kv01 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
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
  }
}

resource kvsecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: secretname
  parent: kv01
  tags: tags
  properties: {
    value: secretvalue
  }
}

resource role02 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid('role02')
  scope: kv01
  properties: {
    principalId: principalId 
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/00482a5a-887f-4fb3-b363-3b7fe8e74483'
  }
}
