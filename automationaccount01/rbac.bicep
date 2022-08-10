targetScope = 'subscription'

param principalId string

var roleDefinitionId1 = 'f353d9bd-d4a6-484e-a77a-8050b599b867'
var roleDefinitionId2 = '5e467623-bb1f-42f4-a55d-6e525e11384b'

resource role 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(subscription().id, principalId, roleDefinitionId1)
  properties: {
    description: 'Automation Contributor'
    principalId: principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId1)
  }
}

resource role2 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(subscription().id, principalId, roleDefinitionId2)
  properties: {
    description: 'Backup Contributor'
    principalId: principalId
     principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId2)
  }
}


