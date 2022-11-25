targetScope = 'subscription'

param principalId string
param role01 string
param role02 string

resource role 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(subscription().id, principalId, role01)
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role01)
    principalType: 'ServicePrincipal'
  }
}

resource role2 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(subscription().id, principalId, role02)
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role02)
    principalType: 'ServicePrincipal'
  }
}
