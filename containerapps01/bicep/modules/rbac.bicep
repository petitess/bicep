param principalId string
param roles ('Network Contributor'
  | 'Key Vault Administrator'
  | 'Key Vault Secrets User'
  | 'Contributor'
  | 'Reader'
  | 'AcrDelete'
  | 'AcrImageSigner'
  | 'AcrPull'
  | 'AcrPush')[]

var rolesList = {
  'Network Contributor': '4d97b98b-1d4f-4787-a291-c67834d212e7'
  'Key Vault Administrator': '00482a5a-887f-4fb3-b363-3b7fe8e74483'
  'Key Vault Secrets User': '4633458b-17de-408a-b874-0445c86b69e6'
  Contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  Reader: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
  AcrDelete: 'c2f4ef07-c644-48eb-af81-4b1b4947fb11'
  AcrImageSigner: '6cef56e8-d556-48e5-a04f-b8e64114680f'
  AcrPull: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
  AcrPush: '8311e382-0749-4cb8-b61a-304f252e45ec'

}

resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = [for role in roles: {
  name: rolesList[role]
  scope: subscription()
}]

resource rbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (role, i) in roles: {
  name: guid(subscription().id, principalId, roleDefinition[i].id)
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinition[i].id
    principalType: 'ServicePrincipal'
  }
}]
