targetScope = 'subscription'

//Create a cutom role
resource customrole 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' = {
  name:  guid('ROLE')
  scope: subscription()
  properties: {
   roleName: 'EnvRole01'
   assignableScopes: [
     subscription().id
   ]
   description: 'Permissions for my environment'
   permissions: [
    {
      actions: [
        'Microsoft.Compute/*'
        'Microsoft.Network/*'
        'Microsoft.Storage/*'
        'Microsoft.KeyVault/*'
        'Microsoft.ManagedIdentity/*'
        'Microsoft.Automation/*'
        'Microsoft.Resources/*'
        'Microsoft.Insights/*'
        'Microsoft.RecoveryServices/*'
        'Microsoft.OperationalInsights/*'
      ]
      notActions: [
        'Microsoft.Authorization/*/Delete'
        'Microsoft.Authorization/*/Write'
        'Microsoft.Authorization/elevateAccess/Action'
        'Microsoft.Blueprint/blueprintAssignments/write'
        'Microsoft.Blueprint/blueprintAssignments/delete'
        'Microsoft.Compute/galleries/share/action'
      ]
    }
  ]
  }
}
