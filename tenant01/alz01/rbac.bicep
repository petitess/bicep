targetScope = 'subscription'

param roleAssignments array

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleAssignment in roleAssignments: {
  name: guid(subscription().id, roleAssignment.principalId, roleAssignment.roleDefinitionId)
  properties: {
    principalId: roleAssignment.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleAssignment.roleDefinitionId)
  }
}]
