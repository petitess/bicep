targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'ACR3'
  properties: {
    displayName: 'ACR3: Retention policy must be activated'
    description: 'Retention policy must be activated'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'Acr'
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
            equals: 'Microsoft.ContainerRegistry/registries'
            field: 'type'
          }
          {
            equals: 'disabled'
            field: 'Microsoft.ContainerRegistry/registries/policies.retentionPolicy.status'
          }
        ]
      }
      then: {
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
