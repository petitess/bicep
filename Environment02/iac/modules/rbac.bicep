targetScope = 'subscription'

param principalId string
param keyvaultadmin string
param contributor string

resource role 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, principalId, keyvaultadmin)
  properties: {
    principalType: 'ServicePrincipal'
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyvaultadmin)
  }
}

resource role2 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(subscription().id, principalId, contributor)
  properties: {
    principalType: 'ServicePrincipal'
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', contributor)
  }
}
