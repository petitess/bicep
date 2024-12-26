targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'SQL5'
  properties: {
    displayName: 'SQL5: No any-to-any rule must be configured'
    description: 'No any-to-any rule must be configured'
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
        ]
        defaultValue: 'Audit'
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
            equals: 'Microsoft.Sql/servers/firewallRules'
            field: 'type'
          }
          {
            allOf: [
              {
                equals: '0.0.0.0'
                field: 'Microsoft.Sql/servers/firewallRules/startIpAddress'
              }
              {
                equals: '255.255.255.255'
                field: 'Microsoft.Sql/servers/firewallRules/endIpAddress'
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
