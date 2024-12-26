targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'AAS1'
  properties: {
    displayName: 'AAS1: Default Backup should not be used'
    description: 'Default Backup should not be used'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'AnalysisServices'
    }
    parameters: {
      effect: {
        allowedValues: [
          'Audit'
          'Deny'
        ]
        defaultValue: 'Deny'
        metadata: {
          description: 'Activate or deactivate the execution of the policy'
          displayName: 'Effect'
        }
        type: 'String'
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            equals: 'Microsoft.AnalysisServices/servers'
            field: 'type'
          }
          {
            exists: true
            field: 'Microsoft.AnalysisServices/servers/backupBlobContainerUri'
          }
        ]
      }
      then: {
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
