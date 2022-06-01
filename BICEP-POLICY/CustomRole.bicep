targetScope = 'subscription'

var ObjectId = 'd55846dc-8d88-4b23-xxxx-84c20b03b98a' 

//Assign user a role
resource perm 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid('USER')
  properties: {
    principalId: ObjectId
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'
  }
}

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
        'Microsoft.Automation/automationAccounts/diagnosticSettings/write'
        'Microsoft.Automation/automationAccounts/certificates/write'
        'Microsoft.Automation/automationAccounts/connections/write'
        'Microsoft.Automation/automationAccounts/connectionTypes/write'
        'Microsoft.Automation/automationAccounts/credentials/write'
        'Microsoft.Automation/automationAccounts/configurations/write'
        'Microsoft.Automation/automationAccounts/hybridRunbookWorkerGroups/write'
        'Microsoft.Automation/automationAccounts/hybridRunbookWorkerGroups/hybridRunbookWorkers/write'
        'Microsoft.Automation/automationAccounts/jobs/write'
        'Microsoft.Automation/automationAccounts/jobSchedules/write'
        'Microsoft.Automation/automationAccounts/modules/write'
        'Microsoft.Automation/automationAccounts/privateEndpointConnections/write'
        'Microsoft.Automation/automationAccounts/privateEndpointConnectionProxies/write'
        'Microsoft.Automation/automationAccounts/python2Packages/write'
        'Microsoft.Automation/automationAccounts/python3Packages/write'
        'Microsoft.Automation/automationAccounts/runbooks/write'
        'Microsoft.Automation/automationAccounts/runbooks/draft/write'
        'Microsoft.Automation/automationAccounts/runbooks/draft/content/write'
        'Microsoft.Automation/automationAccounts/runbooks/draft/testJob/write'
        'Microsoft.Automation/automationAccounts/schedules/write'
        'Microsoft.Automation/automationAccounts/softwareUpdateConfigurations/write'
        'Microsoft.Automation/automationAccounts/variables/write'
        'Microsoft.Automation/automationAccounts/webhooks/write'
        'Microsoft.Automation/automationAccounts/watchers/write'
        'Microsoft.Automation/automationAccounts/watchers/watcherActions/write'
        'Microsoft.Automation/automationAccounts/agentRegistrationInformation/regenerateKey/action'
        'Microsoft.Automation/automationAccounts/compilationjobs/write'
        'Microsoft.Automation/automationAccounts/nodeConfigurations/write'
        'Microsoft.Automation/automationAccounts/nodes/write'
      ]
    }
  ]
  }
}
