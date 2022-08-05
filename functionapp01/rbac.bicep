targetScope = 'subscription'

param principalId string
@description('Backup Contributor')
param roleDefinitionId string = '5e467623-bb1f-42f4-a55d-6e525e11384b'

resource role 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(subscription().id, principalId, roleDefinitionId)
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
  }
}
