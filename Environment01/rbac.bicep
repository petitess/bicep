targetScope = 'subscription'

param principalId string
param role1 string
param role2 string

resource role01 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, principalId, role1)
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role1)
    description: 'Contributor'
    principalType: 'ServicePrincipal'
  }
}

resource role02 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, principalId, role2)
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role2)
    description: 'Key Vault Admin'
    principalType: 'ServicePrincipal'
  }
}
