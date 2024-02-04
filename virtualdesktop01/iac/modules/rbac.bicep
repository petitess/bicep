param principalId string
param roles ('Network Contributor'
  | 'Key Vault Administrator'
  | 'Key Vault Secrets User'
  | 'Virtual Machine User Login'
  | 'Storage File Data SMB Share Contributor'
  | 'Desktop Virtualization Power On Contributor role'
  | 'Contributor'
  | 'Reader')[]

var rolesList = {
  'Network Contributor': '4d97b98b-1d4f-4787-a291-c67834d212e7'
  'Key Vault Administrator': '00482a5a-887f-4fb3-b363-3b7fe8e74483'
  'Key Vault Secrets User': '4633458b-17de-408a-b874-0445c86b69e6'
  'Virtual Machine User Login': 'fb879df8-f326-4884-b1cf-06f3ad86be52'
  'Storage File Data SMB Share Contributor': '0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb'
  'Desktop Virtualization Power On Contributor role': '40c5ff49-9181-41f8-ae61-143b0e78555e'
  Contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  Reader: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'

}

resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = [for role in roles: {
  name: rolesList[role]
  scope: subscription()
}]

resource rbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (role, i) in roles: {
  name: guid(resourceGroup().id, principalId, roleDefinition[i].id)
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinition[i].id
  }
}]
