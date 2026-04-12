param principalId string
param roles (
  | 'Network Contributor'
  | 'Key Vault Administrator'
  | 'Key Vault Secrets User'
  | 'Redis Cache Contributor'
  | 'Contributor'
  | 'Reader')[]
param principalType resourceInput<'Microsoft.Authorization/roleAssignments@2022-04-01'>.properties.principalType = 'ServicePrincipal'

var rolesList = {
  'Network Contributor': '4d97b98b-1d4f-4787-a291-c67834d212e7'
  'Key Vault Administrator': '00482a5a-887f-4fb3-b363-3b7fe8e74483'
  'Key Vault Secrets User': '4633458b-17de-408a-b874-0445c86b69e6'
  'Redis Cache Contributor': 'e0f68234-74aa-48ed-b826-c38b57376e17'
  Contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  Reader: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
}

resource rbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (role, i) in roles: {
    name: guid(subscription().id, principalId, string(i), resourceGroup().name, rolesList[role])
    properties: {
      principalId: principalId
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleAssignments', rolesList[role])
      principalType: principalType
    }
  }
]
