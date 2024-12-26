targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'APP6'
  properties: {
    displayName: 'APP6: Diagnostics logs must enabled'
    description: 'Diagnostics logs must enabled'
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
            allOf: [
              {
                count: {
                  field: 'Microsoft.Insights/diagnosticSettings/logs[*]'
                  where: {
                    allOf: [
                      {
                        equals: 'True'
                        field: 'Microsoft.Insights/diagnosticSettings/logs[*].enabled'
                      }
                      {
                        field: 'Microsoft.Insights/diagnosticSettings/logs[*].Category'
                        in: [
                          'AppServiceHTTPLogs'
                          'AppServiceAuditLogs'
                          'AppServiceIPSecAuditLogs'
                        ]
                      }
                    ]
                  }
                }
                greater: 0
              }
            ]
          }
          type: 'Microsoft.Insights/diagnosticSettings'
        }
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
