targetScope = 'resourceGroup'

param location string
param name string
param kvname string
param roleDefinitionId01 string //= 'b24988ac-6180-42a0-ab88-20f7382dd24c' //Default as contributor role
param roleDefinitionId02 string //= '00482a5a-887f-4fb3-b363-3b7fe8e74483' //Key Vault Administrator
param roleDefinitionId03 string //= '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9' //User Access Administrator


resource Id 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: name
  location: location

}

resource sub 'Microsoft.Subscription/aliases@2021-10-01' existing =  {
  name: 'Azure subscription 1'
  scope: tenant()
}

resource roleassigment01 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(roleDefinitionId01, resourceGroup().id)
  scope: sub
  properties: {
    principalId: Id.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId01)
    principalType: 'ServicePrincipal'
    
  }
}

resource kvExisting 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  scope: resourceGroup() 
  name: kvname
}

resource roleassigment02 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(roleDefinitionId02, resourceGroup().id)
  scope: kvExisting
  properties: {
    principalId: Id.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId02)
    principalType: 'ServicePrincipal'
  }
}

resource roleassigment03 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(roleDefinitionId03, resourceGroup().id)
  properties: {
    principalId: Id.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId03)
    principalType: 'ServicePrincipal'
  }
}

