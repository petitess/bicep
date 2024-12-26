targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'APIM1'
  properties: {
    displayName: 'APIM1: The configuration must contain a CORS block (Global API level)'
    description: 'The configuration must contain a CORS block (Global API level)'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'APIManagment'
    }
    parameters: {
      effect: {
        allowedValues: [
          'Audit'
          'Disabled'
        ]
        defaultValue: 'Audit'
        metadata: {
          description: 'Enable or disable the execution of the policy'
          displayName: 'Effect'
        }
        type: 'String'
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            equals: 'Microsoft.ApiManagement/service/policies'
            field: 'type'
          }
          {
            contains: '<origin>*</origin>'
            field: 'Microsoft.ApiManagement/service/policies/value'
          }
        ]
      }
      then: {
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
