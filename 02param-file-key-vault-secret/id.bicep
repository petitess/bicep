targetScope = 'resourceGroup'

param location string
param name string
param roleDefinitionId01 string //= 'b24988ac-6180-42a0-ab88-20f7382dd24c' //Default as contributor role
param roleDefinitionId02 string //= '00482a5a-887f-4fb3-b363-3b7fe8e74483' //Key Vault Administrator
param roleDefinitionId03 string //= '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9' //User Access Administrator


resource Id 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: name
  location: location

}

resource roleassigment01 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(roleDefinitionId01, resourceGroup().id)
  properties: {
    principalId: Id.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId01)
    principalType: 'ServicePrincipal'
  }
}

resource roleassigment02 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(roleDefinitionId02, resourceGroup().id)
  properties: {
    principalId: Id.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId02)
    principalType: 'ServicePrincipal'
    //delegatedManagedIdentityResourceId: subscription().id  
  }
}

resource roleassigment03 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(roleDefinitionId03, resourceGroup().id)
  properties: {
    principalId: Id.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId03)
    principalType: 'ServicePrincipal'
    //delegatedManagedIdentityResourceId: tenant().tenantId
  }
}
/*
The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: 
@Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase 'foo_storage_container'
/subscriptions/2d9f44ea-e3df-4ea1-b956-8c7a43b119a0/resourceGroups/rg-script-prod-sc-01/providers/Microsoft.Resources/deployments/module-prod-id01/operations/FA2FE5B151C98EF4
*/
