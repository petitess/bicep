targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'APIM2'
  properties: {
    displayName: 'APIM2: System managed Identity must be enabled'
    description: 'System managed Identity must be enabled'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'APIManagment'
    }
    parameters: {
      effect: {
        allowedValues: [
          'Audit'
          'Deny'
        ]
        defaultValue: 'Audit'
        metadata: {
          description: 'Enforce or Audit the execution of the policy'
          displayName: 'Effect'
        }
        type: 'String'
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            equals: 'Microsoft.ApiManagement/service'
            field: 'type'
          }
          {
            anyOf: [
              {
                notEquals: 'SystemAssigned'
                value: '''[field('identity.type')]'''
              }
              {
                exists: false
                field: 'identity.type'
              }
              {
                equals: 'None'
                field: 'identity.type'
              }
            ]
          }
        ]
      }
      then: {
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
