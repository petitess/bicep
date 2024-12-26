targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'APP12'
  properties: {
    displayName: 'APP12: Web App Minimum_tls_version must be 1.2 or 1.3'
    description: 'Web App Minimum_tls_version must be 1.2 or 1.3'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'AppService'
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
            notContains: 'functionapp'
          }
        ]
      }
      then: {
        details: {
          deployment: {
            properties: {
              mode: 'incremental'
              parameters: {
                siteName: {
                  value: '''[field('name')]'''
                }
              }
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                outputs: {}
                parameters: {
                  siteName: {
                    type: 'string'
                  }
                }
                resources: [
                  {
                    apiVersion: '2021-02-01'
                    name: '''[concat(parameters('siteName'), '/web')]'''
                    properties: {
                      minTlsVersion: '1.2'
                    }
                    type: 'Microsoft.Web/sites/config'
                  }
                ]
                variables: {}
              }
            }
          }
          existenceCondition: {
            field: 'Microsoft.Web/sites/config/minTlsVersion'
            greaterOrEquals: '1.2'
          }
          name: 'web'
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/de139f84-1756-47ae-9be6-808fbbe84772'
          ]
          type: 'Microsoft.Web/sites/config'
        }
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
