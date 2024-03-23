param principalId string
param roles (
  | 'Network Contributor'
  | 'Key Vault Administrator'
  | 'Key Vault Secrets User'
  | 'Monitoring Contributor'
  | 'Contributor'
  | 'Reader'
  | 'Storage File Data Privileged Contributor')[]

var rolesList = {
  'Network Contributor': '4d97b98b-1d4f-4787-a291-c67834d212e7'
  'Key Vault Administrator': '00482a5a-887f-4fb3-b363-3b7fe8e74483'
  'Key Vault Secrets User': '4633458b-17de-408a-b874-0445c86b69e6'
  'Monitoring Contributor': '749f88d5-cbae-40b8-bcfc-e573ddc772fa'
  Contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  Reader: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
  'Storage File Data Privileged Contributor': '69566ab7-960f-475b-8e7c-b3118f30c6bd'
}

resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = [
  for role in roles: {
    name: rolesList[role]
    scope: subscription()
  }
]

resource rbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (role, i) in roles: {
    name: guid(subscription().id, resourceGroup().id, principalId, roleDefinition[i].id)
    properties: {
      principalId: principalId
      roleDefinitionId: roleDefinition[i].id
      principalType: 'ServicePrincipal'
    }
  }
]
