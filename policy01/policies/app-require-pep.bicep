targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'APP9'
  properties: {
    displayName: 'APP9: App Service Private endpoint must be configured'
    description: 'App Service Private endpoint must be configured'
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
            equals: 'Approved'
            field: 'Microsoft.Web/sites/privateEndpointConnections/privateLinkServiceConnectionState.status'
          }
          type: 'Microsoft.Web/sites/privateEndpointConnections'
        }
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
