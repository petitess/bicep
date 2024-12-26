targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'APP4'
  properties: {
    displayName: 'APP4: CORS should not allow every resource to access your APPS'
    description: 'CORS should not allow every resource to access your APPS'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'AppService'
    }
    parameters: {
      effect: {
        allowedValues: [
          'Audit'
          'DeployIfNotExists'
          'Deny'
        ]
        defaultValue: 'DeployIfNotExists'
        metadata: {
          description: 'Enforce or Audit the execution of the policy'
          displayName: 'Effect'
        }
        type: 'String'
      }
      forbiddenOrigins: {
        allowedValues: [
          '*'
        ]
        defaultValue: [
          '*'
        ]
        metadata: {
          description: 'List of urls forbidden for CORS'
          displayName: 'Forbidden CORS origins'
        }
        type: 'Array'
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
                '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
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
                      cors: {
                        allowedOrigins: []
                      }
                    }
                    type: 'Microsoft.Web/sites/config'
                  }
                ]
              }
            }
          }
          evaluationDelay: 'PT5M'
          existenceCondition: {
            field: 'Microsoft.Web/sites/config/web.cors.allowedOrigins[*]'
            notIn: '''[parameters('forbiddenOrigins')]'''
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
