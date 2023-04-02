targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var contributor = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
var group = 'de2eb3c0-045a-4c26-979c-d5f9bf0966fc'

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${affix}-sc-02'
  location: param.location
  tags: param.tags
}

resource rbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, rg.name, contributor, group)
  properties: {
    principalId: group
    roleDefinitionId: contributor
    principalType: 'Group'
  }
}

output s string = subscription().displayName
