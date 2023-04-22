targetScope = 'subscription'

param principalId string
param roles array

var rolesList = {
  Contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  Owner: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
  Reader: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
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
  }
}]
