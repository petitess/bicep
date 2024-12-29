targetScope = 'subscription'

param idId string = ''
param location string = deployment().location

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'ST5'
  properties: {
    displayName: 'ST5: CORS must not allow all origins (Blob Services)'
    description: 'CORS must not allow all origins (Blob Services)'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'Storage'
    }
    parameters: {
      effect: {
        allowedValues: [
          'Disable'
          'DeployIfNotExists'
        ]
        defaultValue: 'DeployIfNotExists'
        metadata: {
          description: 'Activate or deactivate the execution of the policy'
          displayName: 'Effect'
        }
        type: 'String'
      }
    }
    policyRule: {
      if: {
        equals: 'Microsoft.Storage/storageAccounts'
        field: 'type'
      }
      then: {
        details: {
          deployment: {
            properties: {
              mode: 'incremental'
              parameters: {
                kind: {
                  value: '''[field('kind')]'''
                }
                location: {
                  value: '''[field('location')]'''
                }
                name: {
                  value: '''[field('name')]'''
                }
              }
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  kind: {
                    type: 'string'
                  }
                  location: {
                    type: 'string'
                  }
                  name: {
                    type: 'string'
                  }
                }
                resources: [
                  {
                    apiVersion: '2021-06-01'
                    kind: '''[parameters('kind')]'''
                    location: '''[parameters('location')]'''
                    name: '''[concat(parameters('name'), '/default')]'''
                    properties: {
                      cors: {
                        corsRules: []
                      }
                    }
                    type: 'Microsoft.Storage/storageAccounts/blobServices'
                  }
                ]
              }
            }
          }
          existenceCondition: {
            allOf: [
              {
                exists: 'true'
                field: 'Microsoft.Storage/storageAccounts/blobServices/cors.corsRules[*]'
              }
              {
                count: {
                  field: 'Microsoft.Storage/storageAccounts/blobServices/cors.corsRules[*]'
                  where: {
                    contains: '*'
                    field: 'Microsoft.Storage/storageAccounts/blobServices/cors.corsRules[*].allowedOrigins[*]'
                  }
                }
                equals: 0
              }
            ]
          }
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
          ]
          type: 'Microsoft.Storage/storageAccounts/blobServices'
        }
        effect: '''[parameters('effect')]'''
      }
    }
  }
}

resource assignment 'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: 'assigment-${definition.name}'
  location: location
  properties: {
    displayName: 'assigment-${definition.properties.displayName}'
    description: definition.properties.description
    notScopes: []
    enforcementMode: 'Default'
    policyDefinitionId: definition.id
    parameters: {
      effect: {
        value: definition.properties.parameters['effect'].defaultValue
      }
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${idId}': {}
    }
  }
}
