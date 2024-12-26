targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'SQL6'
  properties: {
    displayName: 'SQL6: Advanced Data Security must be configured'
    description: 'Advanced Data Security must be configured'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'Sql'
    }
    parameters: {
      effect: {
        allowedValues: [
          'AuditIfNotExists'
          'disabled'
        ]
        defaultValue: 'AuditIfNotExists'
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
            anyof: [
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
            equals: 'Microsoft.Sql/servers'
            field: 'type'
          }
          {
            field: 'kind'
            notContains: 'analytics'
          }
        ]
      }
      then: {
        details: {
          existenceCondition: {
            equals: 'Enabled'
            field: 'Microsoft.Sql/servers/securityAlertPolicies/state'
          }
          name: 'Default'
          type: 'Microsoft.Sql/servers/securityAlertPolicies'
        }
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
