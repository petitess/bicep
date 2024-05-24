param principalId string
param roles (
  | 'Network Contributor'
  | 'Key Vault Administrator'
  | 'Key Vault Secrets User'
  | 'Contributor'
  | 'Reader'
  | 'Backup Contributor'
  | 'Storage Account Backup Contributor'
  | 'Disk Backup Reader')[]

var rolesList = {
  'Network Contributor': '4d97b98b-1d4f-4787-a291-c67834d212e7'
  'Key Vault Administrator': '00482a5a-887f-4fb3-b363-3b7fe8e74483'
  'Key Vault Secrets User': '4633458b-17de-408a-b874-0445c86b69e6'
  Contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  Reader: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
  'Backup Contributor': '5e467623-bb1f-42f4-a55d-6e525e11384b'
  'Storage Account Backup Contributor' : 'e5e2a7ff-d759-4cd2-bb51-3152d37e2eb1'
  'Disk Backup Reader': '3e5e47e6-65f7-47ef-90b5-e5dd4d455f24'
}

resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = [
  for role in roles: {
    name: rolesList[role]
    scope: subscription()
  }
]

resource rbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (role, i) in roles: {
    name: guid(subscription().id, principalId, roleDefinition[i].id)
    properties: {
      principalId: principalId
      roleDefinitionId: roleDefinition[i].id
      principalType: 'ServicePrincipal'
    }
  }
]
