targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'ST4'
  properties: {
    displayName: 'ST4: Azure defender for storage must be enabled'
    description: 'Azure defender for storage must be enabled'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'Storage'
    }
    parameters: {
      effect: {
        allowedValues: [
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
      tagValue: {
        allowedValues: [
          'APPI'
        ]
        defaultValue: [
          'APPI'
        ]
        metadata: {
          description: 'The list of allowed tag'
          displayName: 'Tag Value'
        }
        type: 'array'
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            equals: 'Microsoft.Storage/storageAccounts'
            field: 'type'
          }
          {
            In: '''[parameters('tagValue')]'''
            field: 'tags.Resource_ControlTower_Profile'
          }
        ]
      }
      then: {
        details: {
          deployment: {
            properties: {
              mode: 'incremental'
              parameters: {
                storageAccountName: {
                  value: '''[field('name')]'''
                }
              }
              template: {
                '$schema': 'http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  storageAccountName: {
                    type: 'string'
                  }
                }
                resources: [
                  {
                    apiVersion: '2019-01-01'
                    name: '''[concat(parameters('storageAccountName'), '/Microsoft.Security/current')]'''
                    properties: {
                      isEnabled: true
                    }
                    type: 'Microsoft.Storage/storageAccounts/providers/advancedThreatProtectionSettings'
                  }
                ]
              }
            }
          }
          existenceCondition: {
            equals: 'true'
            field: 'Microsoft.Security/advancedThreatProtectionSettings/isEnabled'
          }
          name: 'current'
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
          ]
          type: 'Microsoft.Security/advancedThreatProtectionSettings'
        }
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
