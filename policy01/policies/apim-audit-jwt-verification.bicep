targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'APIM3'
  properties: {
    displayName: 'APIM3: Enforce JWT verification (Global API Policies)'
    description: 'Enforce JWT verification (Global API Policies)'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'AppService'
    }
    parameters: {
      effect: {
        allowedValues: [
          'AuditIfNotExists'
          'Disabled'
        ]
        defaultValue: 'AuditIfNotExists'
        metadata: {
          description: 'Enable or disable the execution of the policy'
          displayName: 'Effect'
        }
        type: 'String'
      }
    }
    policyRule: {
      if: {
        equals: 'Microsoft.ApiManagement/service'
        field: 'type'
      }
      then: {
        details: {
          existenceCondition: {
            contains: '<validate-jwt header-name='
            field: 'Microsoft.ApiManagement/service/policies/value'
          }
          type: 'Microsoft.ApiManagement/service/policies'
        }
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
