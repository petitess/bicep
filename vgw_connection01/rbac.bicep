targetScope = 'subscription'

param principalId string
var roleDefinitionId = '00482a5a-887f-4fb3-b363-3b7fe8e74483'

resource role 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(subscription().id, principalId, roleDefinitionId)
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
  }
}
