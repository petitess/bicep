targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'ST3'
  properties: {
    displayName: 'ST3: IP rules must be set to Deny traffic from Internet'
    description: 'IP rules must be set to Deny traffic from Internet'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'Storage'
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
            allOf: [
              {
                equals: 'Microsoft.Storage/storageAccounts'
                field: 'type'
              }
            ]
          }
          {
            anyOf: [
              {
                field: 'Microsoft.Storage/storageAccounts/networkAcls.defaultAction'
                notEquals: 'Deny'
              }
              {
                count: {
                  field: 'Microsoft.Storage/storageAccounts/networkAcls.ipRules[*]'
                }
                notequals: 0
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
