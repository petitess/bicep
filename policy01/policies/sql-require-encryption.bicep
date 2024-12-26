targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'SQL3'
  properties: {
    displayName: 'SQL3: Allow only Ecrypted Database'
    description: 'Allow only Ecrypted Database'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'Sql'
    }
    parameters: {
      effect: {
        allowedValues: [
          'Audit'
          'Deny'
          'Disabled'
        ]
        defaultValue: 'Deny'
        metadata: {
          description: 'The effect determines what happens when the policy rule is evaluated to match'
          displayName: 'Effect'
        }
        type: 'String'
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            equals: 'Microsoft.Sql/servers/databases/transparentDataEncryption'
            field: 'type'
          }
          {
            equals: 'disabled'
            field: 'Microsoft.Sql/servers/databases/transparentDataEncryption/status'
          }
        ]
      }
      then: {
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
