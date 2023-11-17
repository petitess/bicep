targetScope = 'tenant'

var mgId = 'xxx-ae44-48b7-a392-b6cdf9e27afc'
var owner = '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
var contributor = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
var prinicpal1 = 'xxx-2004-4771-a110-ca70ae014313'
var prinicpal2 = 'xxx-7552-4919-8597-aa02cbec01ac'

resource mgE 'Microsoft.Management/managementGroups@2021-04-01' existing = {
  name: mgId
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(mgE.id, prinicpal1, owner)
  properties: {
    principalId: prinicpal1
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', owner)
  }
}

resource roleAssignment2 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(mgE.id, prinicpal2, contributor)
  properties: {
    principalId: prinicpal2
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', contributor)
  }
}
