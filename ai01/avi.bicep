param name string
param stId string
param oaiId string
param rbac (
  | 'Storage Queue Data Contributor'
  | 'Storage Table Data Contributor'
  | 'Storage Blob Data Contributor'
  | 'Storage File Data Privileged Contributor'
  | 'Cognitive Services User'
  | 'Cognitive Services Contributor')[] = []

var rolesList = {
  'Storage Queue Data Contributor': '974c5e8b-45b9-4653-ba55-5f855dd0fb88'
  'Storage Table Data Contributor': '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'
  'Storage Blob Data Contributor': 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
  'Storage File Data Privileged Contributor': '69566ab7-960f-475b-8e7c-b3118f30c6bd'
  'Cognitive Services User': 'a97b65f3-24c7-4388-baec-2e87135dc908'
  'Cognitive Services Contributor': '25fbc0a9-bd7c-42a3-aa1a-3b75d497ee68'
}

resource avi 'Microsoft.VideoIndexer/accounts@2025-04-01' = {
  name: name
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    storageServices: {
      resourceId: stId
    }
    openAiServices: {
      resourceId: oaiId
    }
    publicNetworkAccess: 'Enabled'
  }
}

resource rbacR 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (r, i) in rbac: if (rbac != []) {
    name: guid(resourceGroup().id, avi.id, r, string(i))
    properties: {
      principalId: avi.identity.principalId
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleAssignments', rolesList[r])
      principalType: 'ServicePrincipal'
    }
  }
]
