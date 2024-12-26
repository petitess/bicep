targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'APP8'
  properties: {
    displayName: 'APP8: The App must not have an embedded mysql DB'
    description: 'The App must not have an embedded mysql DB'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'AppService'
    }
    parameters: {
      effect: {
        allowedValues: [
          'AuditIfNotExists'
          'Deny'
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
            equals: 'Microsoft.Web/sites'
            field: 'type'
          }
          {
            field: 'kind'
            like: 'app*'
          }
        ]
      }
      then: {
        details: {
          existenceCondition: {
            equals: 'false'
            field: 'Microsoft.Web/sites/config/localMySqlEnabled'
          }
          type: 'Microsoft.Web/sites/config'
        }
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
