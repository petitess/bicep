targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'ALB1'
  properties: {
    displayName: 'ALB1: Diagnostics settings must be enabled for Internal Load Balancer'
    description: 'Diagnostics settings must be enabled for Internal Load Balancer'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'LoadBalancer'
    }
    parameters: {
      EventHubAuthorizationRuleName: {
        defaultValue: '/authorizationrules/RootManageSharedAccessKey'
        metadata: {
          description: 'Authorization Rule Name to access the Event Hub'
          displayName: 'Authorizarion Rule Name to access the Event Hub'
        }
        type: 'String'
      }
      EventHubName: {
        defaultValue: 'evh-security-governance-prd-'
        metadata: {
          description: 'first part to retrieve the Event Hub corresponding resource group'
          displayName: 'first part to retrieve the Event Hub corresponding resource group'
        }
        type: 'String'
      }
      EventHubNamespaceName: {
        defaultValue: '/providers/Microsoft.EventHub/namespaces/evh-ns-security-governance-prd-'
        metadata: {
          description: 'first part to retrieve the Event Hub corresponding resource group'
          displayName: 'first part to retrieve the Event Hub corresponding resource group'
        }
        type: 'String'
      }
      ResourceGroupName: {
        defaultValue: '/subscriptions/ab883f14-0eb6-480b-995f-4b6340159245/resourcegroups/rg-security-governance-prd-'
        metadata: {
          description: 'first part to retrieve the Event Hub corresponding resource group'
          displayName: 'first part to retrieve the Event Hub corresponding resource group'
        }
        type: 'String'
      }
      diagnosticSettingName: {
        defaultValue: 'EventHub'
        metadata: {
          description: 'Diagnostic Setting Name'
          displayName: 'Diagnostic Setting Name'
        }
        type: 'String'
      }
      effect: {
        allowedValues: [
          'DeployIfNotExists'
          'AuditIfNotExists'
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
            equals: 'Microsoft.Network/loadBalancers'
            field: 'type'
          }
        ]
      }
      then: {
        details: {
          deployment: {
            properties: {
              mode: 'incremental'
              parameters: {
                EventHubAuthorizationRuleName: {
                  value: '''[parameters('EventHubAuthorizationRuleName')]'''
                }
                EventHubName: {
                  value: '''[parameters('EventHubName')]'''
                }
                EventHubNamespaceName: {
                  value: '''[parameters('EventHubNamespaceName')]'''
                }
                ResourceGroupName: {
                  value: '''[parameters('ResourceGroupName')]'''
                }
                diagnosticSettingName: {
                  value: '''[parameters('diagnosticSettingName')]'''
                }
                location: {
                  value: '''[field('location')]'''
                }
                resourceName: {
                  value: '''[field('name')]'''
                }
              }
              template: {
                '$schema': 'http://schema.management.azure.com/schemas/2019-08-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  EventHubAuthorizationRuleName: {
                    type: 'string'
                  }
                  EventHubName: {
                    type: 'string'
                  }
                  EventHubNamespaceName: {
                    type: 'string'
                  }
                  ResourceGroupName: {
                    type: 'string'
                  }
                  diagnosticSettingName: {
                    type: 'string'
                  }
                  location: {
                    type: 'string'
                  }
                  resourceName: {
                    type: 'string'
                  }
                }
                resources: [
                  {
                    apiVersion: '2021-05-01-preview'
                    name: '''[concat(parameters('resourceName'), '/', 'Microsoft.Insights/', parameters('resourceName'), '-', parameters('diagnosticSettingName'))]'''
                    properties: {
                      eventHubAuthorizationRuleId: '''[concat(parameters('ResourceGroupName'),parameters('location'),parameters('EventHubNamespaceName'),parameters('location'),parameters('EventHubAuthorizationRuleName'))]'''
                      eventHubName: '''[concat(parameters('EventHubName'),parameters('location'))]'''
                      logs: [
                        {
                          category: 'LoadBalancerHealthEvent'
                          enabled: true
                        }
                      ]
                      metrics: []
                    }
                    type: 'Microsoft.Network/loadBalancers/providers/diagnosticSettings'
                  }
                ]
                variables: {}
              }
            }
          }
          existenceCondition: {
            allOf: [
              {
                count: {
                  field: 'Microsoft.Insights/diagnosticSettings/logs[*]'
                  where: {
                    allOf: [
                      {
                        equals: true
                        field: 'Microsoft.Insights/diagnosticSettings/logs[*].enabled'
                      }
                      {
                        equals: 'LoadBalancerHealthEvent'
                        field: 'microsoft.insights/diagnosticSettings/logs[*].category'
                      }
                    ]
                  }
                }
                equals: 1
              }
              {
                equals: '''[concat(parameters('ResourceGroupName'),field('location'),parameters('EventHubNamespaceName'),field('location'),parameters('EventHubAuthorizationRuleName'))]'''
                field: 'Microsoft.Insights/diagnosticSettings/eventHubAuthorizationRuleId'
              }
              {
                equals: '''[concat(parameters('EventHubName'),field('location'))]'''
                field: 'Microsoft.Insights/diagnosticSettings/eventHubName'
              }
            ]
          }
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
          ]
          type: 'Microsoft.Insights/diagnosticSettings'
        }
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
