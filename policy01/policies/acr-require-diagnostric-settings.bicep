targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'ACR2'
  properties: {
    displayName: 'ACR2: Diagnostic logs for user-driven events (pull/push etc) in your registry must be logged within Azure Monitor'
    description: 'Diagnostic logs for user-driven events (pull/push etc) in your registry must be logged within Azure Monitor'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'Acr'
    }
    parameters: {
      effect: {
        allowedValues: [
          'AuditIfNotExists'
          'Disabled'
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
        equals: 'Microsoft.ContainerRegistry/registries'
        field: 'type'
      }
      then: {
        details: {
          existenceCondition: {
            equals: 'true'
            field: 'Microsoft.Insights/diagnosticSettings/logs.enabled'
          }
          type: 'Microsoft.Insights/diagnosticSettings'
        }
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
