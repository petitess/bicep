targetScope = 'subscription'

param param object

var env = toLower(param.tags.Environment)

resource rglogic 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  location: param.location
  tags: union(param.tags, {
      Application: 'Resource Graph Query'
    })
  name: 'rg-logic-${env}-01'
}

module logic 'logic.bicep' = {
  scope: rglogic
  name: 'module-logic'
  params: {
    env: env
    location: param.location
  }
}

resource role 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, logic.name, param.id.reader)
  properties: {
    principalType: 'ServicePrincipal'
    description: 'Permission to run a Resource Graph Query'
    principalId: logic.outputs.pricipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', param.id.reader)
  }
}
