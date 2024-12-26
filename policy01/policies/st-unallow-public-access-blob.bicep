targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'ST1'
  properties: {
    displayName: 'ST1: Public blob access is not authorized'
    description: 'Public blob access is not authorized'
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
          'Disabled'
        ]
        defaultValue: 'Audit'
        metadata: {
          description: 'Activate or deactivate the execution of the policy'
          displayName: 'Effect'
        }
        type: 'String'
      }
      networkProfileValues: {
        allowedValues: [
          'publicBlob'
        ]
        defaultValue: [
          'publicBlob'
        ]
        metadata: {
          description: 'The list of resource profile tags not involved in this policy'
          displayName: 'Resource profile tag value'
        }
        type: 'array'
      }
      tagResourceProfile: {
        defaultValue: 'Resource_ControlTower_Profile'
        metadata: {
          description: 'Resource profile tag'
          displayName: 'Resource_ControlTower_Profile'
        }
        type: 'String'
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            equals: 'Microsoft.Storage/storageAccounts'
            field: 'type'
          }
          {
            field: '''[concat('tags[', parameters('tagResourceProfile'), ']')]'''
            notIn: '''[parameters('networkProfileValues')]'''
          }
          {
            notIn: [
              'APPIO'
            ]
            value: '''[toUpper(subscription().tags['spoke_type'])]'''
          }
          {
            field: 'id'
            notContains: '/resourceGroups/databricks-rg-'
          }
          {
            not: {
              equals: 'false'
              field: 'Microsoft.Storage/storageAccounts/allowBlobPublicAccess'
            }
          }
        ]
      }
      then: {
        effect: '''[parameters('effect')]'''
      }
    }
    
  }
}
