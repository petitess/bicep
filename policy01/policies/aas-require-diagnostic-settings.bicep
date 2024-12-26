targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'AAS4'
  properties: {
    displayName: 'AAS4: Diagnostic settings must be enabled'
    description: 'Diagnostic settings must be enabled'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'AnalysisServices'
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
        equals: 'Microsoft.AnalysisServices/servers'
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
