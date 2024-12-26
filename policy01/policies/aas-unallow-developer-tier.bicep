targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'AAS3'
  properties: {
    displayName: 'AAS3: Developer tier must not be used in production environment'
    description: 'Developer tier must not be used in production environment'
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
            anyOf: [
              {
                equals: 'PRD'
                value: '''[toUpper(subscription().tags['environment'])]'''
              }
              {
                like: '*-PRD'
                value: '''[toUpper(subscription().displayName)]'''
              }
              {
                equals: 'PRD'
                value: '''[split(toUpper(subscription().displayName), '-')[2]]'''
              }
            ]
          }
          {
            equals: 'Microsoft.AnalysisServices/servers'
            field: 'type'
          }
          {
            equals: 'Development'
            field: 'Microsoft.AnalysisServices/servers/sku.tier'
          }
        ]
      }
      then: {
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
