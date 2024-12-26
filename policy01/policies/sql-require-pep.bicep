targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'SQL2'
  properties: {
    displayName: 'SQL2: Private endpoint must be enabled and assigned  & No vnet rule must be configured'
    description: 'Private endpoint must be enabled and assigned  & No vnet rule must be configured'
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
      tagResourceProfile: {
        defaultValue: 'Resource_ControlTower_Profile'
        metadata: {
          description: 'Resource_profile tag'
          displayName: 'Resource_ControlTower_Profile'
        }
        type: 'String'
      }
      tagResourceProfileValue: {
        defaultValue: 'SGNET'
        metadata: {
          description: 'The list of allowed tag'
          displayName: 'Tag Value'
        }
        type: 'string'
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            equals: 'Microsoft.DocumentDB/databaseAccounts'
            field: 'type'
          }
          {
            equals: '''[parameters('tagResourceProfileValue')]'''
            field: '''[concat('tags[', parameters('tagResourceProfile'), ']')]'''
          }
          {
            anyOf: [
              {
                exists: 'false'
                field: 'Microsoft.DocumentDB/databaseAccounts/privateEndpointConnections'
              }
              {
                count: {
                  field: 'Microsoft.DocumentDB/databaseAccounts/privateEndpointConnections[*]'
                }
                equals: 0
              }
              {
                field: 'Microsoft.DocumentDB/databaseAccounts/isVirtualNetworkFilterEnabled'
                notEquals: 'true'
              }
              {
                exists: 'true'
                field: 'Microsoft.DocumentDB/databaseAccounts/virtualNetworkRules[*].id'
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
