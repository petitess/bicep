targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'FUNC1'
  properties: {
    displayName: 'FUNC1: FTPS / git accounts must be disabled'
    description: 'FTPS / git accounts must be disabled'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'FunctionApp'
    }
    parameters: {
      effect: {
        allowedValues: [
          'AuditIfNotExists'
          'DeployIfNotExists'
          'Disabled'
        ]
        defaultValue: 'AuditIfNotExists'
        metadata: {
          description: 'Enable or disable the execution of the policy'
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
            like: 'functionapp*'
          }
          {
            field: 'kind'
            notContains: 'workflowapp'
          }
        ]
      }
      then: {
        details: {
          deployment: {
            properties: {
              mode: 'incremental'
              parameters: {
                location: {
                  value: '''[field('location')]'''
                }
                webAppName: {
                  value: '''[field('name')]'''
                }
              }
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  location: {
                    type: 'string'
                  }
                  webAppName: {
                    type: 'string'
                  }
                }
                resources: [
                  {
                    apiVersion: '2021-02-01'
                    location: '''[parameters('location')]'''
                    name: '''[concat(parameters('webAppName'), '/web')]'''
                    properties: {
                      ftpsState: 'Disabled'
                    }
                    type: 'Microsoft.Web/sites/config'
                  }
                ]
              }
            }
          }
          existenceCondition: {
            equals: 'disabled'
            field: 'Microsoft.Web/sites/config/ftpsState'
          }
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
          ]
          type: 'Microsoft.Web/sites/config'
        }
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
