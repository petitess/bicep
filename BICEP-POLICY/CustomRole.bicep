targetScope = 'subscription'

//Create a cutom role
resource customrole 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' = {
  name:  guid('ROLE')
  scope: subscription()
  properties: {
   roleName: 'ContributorWithoutAA'
   assignableScopes: [
     subscription().id
   ]
   description: 'Contributor without Automation Account permission'
   permissions: [
    {
      actions: [
        '*'
      ]
      notActions: [
        'Microsoft.Authorization/*/Delete'
        'Microsoft.Authorization/*/Write'
        'Microsoft.Authorization/elevateAccess/Action'
        'Microsoft.Blueprint/blueprintAssignments/write'
        'Microsoft.Blueprint/blueprintAssignments/delete'
        'Microsoft.Compute/galleries/share/action'
        'Microsoft.Automation/automationAccounts/write'
        'Microsoft.Automation/automationAccounts/*/Write'
        'Microsoft.Automation/automationAccounts/*/Delete'
      ]
    }
  ]
  }
}
