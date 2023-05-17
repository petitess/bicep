targetScope = 'subscription'

param principalId string
param roles array

var rolesList = {
  'Network Contributor': '4d97b98b-1d4f-4787-a291-c67834d212e7'
  'Key Vault Administrator': '00482a5a-887f-4fb3-b363-3b7fe8e74483'
  'Key Vault Secrets User': '4633458b-17de-408a-b874-0445c86b69e6'
  'Monitoring Contributor': '749f88d5-cbae-40b8-bcfc-e573ddc772fa'
  Contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  Reader: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
  Owner: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
}

resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = [for role in roles: {
  name: rolesList[role]
  scope: subscription()
}]

resource rbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (role, i) in roles: {
  name: guid(subscription().id, principalId, roleDefinition[i].id)
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinition[i].id
    principalType: 'ServicePrincipal'
  }
}]
