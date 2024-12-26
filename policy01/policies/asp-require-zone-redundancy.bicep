targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'ASP1'
  properties: {
    displayName: 'ASP1: For availability needs A3, zone redundant App Service Plan must be enabled'
    description: 'For availability needs A3, zone redundant App Service Plan must be enabled'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'AppService'
    }
    parameters: {
      effect: {
        allowedValues: [
          'Audit'
          'Deny'
        ]
        defaultValue: 'Deny'
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
            equals: 'Microsoft.Web/serverFarms'
            field: 'type'
          }
          {
            in: [
              'A3'
              'A4'
            ]
            value: '''[toUpper(subscription().tags['availability'])]'''
          }
          {
            equals: 'false'
            field: 'Microsoft.Web/serverFarms/zoneRedundant'
          }
        ]
      }
      then: {
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
