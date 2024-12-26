targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'APP11'
  properties: {
    displayName: 'APP11: WebApp Firewall must only allow access from specific IPs'
    description: 'WebApp Firewall must only allow access from specific IPs'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'AppService'
    }
    parameters: {
      WAFIPs: {
        allowedValues: [
          '199.83.1.0/21'
          '198.143.1.0/19'
          '149.126.1.0/21'
          '103.28.1.0/22'
        ]
        defaultValue: [
          '199.83.1.0/21'
          '198.143.1.0/19'
          '149.126.1.0/21'
          '103.28.1.0/22'
        ]
        metadata: {
          description: 'The list of WAF IPs addresses'
          displayName: 'WAF IPs'
        }
        type: 'array'
      }
      effect: {
        allowedValues: [
          'DeployIfNotExists'
          'Disabled'
        ]
        defaultValue: 'DeployIfNotExists'
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
            equals: 'APPIO'
            value: '''[toUpper(subscription().tags['spoke_type'])]'''
          }
        ]
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
                    apiVersion: '2021-02-01'
                    location: '''[parameters('location')]'''
                    name: '''[concat(parameters('name'), '/web')]'''
                    properties: {
                      ipSecurityRestrictions: [
                        {
                          action: 'Allow'
                          description: 'Deny all access'
                          ipAddress: '198.143.1.0/19'
                          name: 'Imperva IP'
                          priority: 100
                        }
                        {
                          action: 'Allow'
                          description: 'Deny all access'
                          ipAddress: '149.126.1.0/21'
                          name: 'Imperva IP'
                          priority: 101
                        }
                        {
                          action: 'Allow'
                          description: 'Deny all access'
                          ipAddress: '103.28.1.0/22'
                          name: 'Imperva IP'
                          priority: 102
                        }
                        {
                          action: 'Allow'
                          description: 'Deny all access'
                          ipAddress: '192.230.1.0/18'
                          name: 'Imperva IP'
                          priority: 102
                        }
                        {
                          action: 'Allow'
                          description: 'Deny all access'
                          ipAddress: '45.64.1.0/22'
                          name: 'Imperva IP'
                          priority: 103
                        }
                        {
                          action: 'Allow'
                          description: 'Deny all access'
                          ipAddress: '107.154.0.0/16'
                          name: 'Imperva IP'
                          priority: 104
                        }
                        {
                          action: 'Allow'
                          description: 'Deny all access'
                          ipAddress: '45.1.0.0/16'
                          name: 'Imperva IP'
                          priority: 105
                        }
                        {
                          action: 'Allow'
                          description: 'Deny all access'
                          ipAddress: '45.1.0.0/16'
                          name: 'Imperva IP'
                          priority: 106
                        }
                        {
                          action: 'Deny'
                          description: 'Deny all access'
                          ipAddress: 'Any'
                          name: 'Deny all'
                          priority: 2147483647
                        }
                      ]
                    }
                    type: 'Microsoft.Web/sites/config'
                  }
                ]
              }
            }
          }
          existenceCondition: {
            not: {
              anyOf: [
                {
                  count: {
                    field: 'Microsoft.Web/sites/config/ipSecurityRestrictions[*]'
                    where: {
                      allOf: [
                        {
                          field: 'Microsoft.Web/sites/config/ipSecurityRestrictions[*].ipAddress'
                          notIn: '''[parameters('WAFIPs')]'''
                        }
                        {
                          equals: 'Allow'
                          field: 'Microsoft.Web/sites/config/ipSecurityRestrictions[*].action'
                        }
                      ]
                    }
                  }
                  notEquals: 0
                }
                {
                  count: {
                    field: 'Microsoft.Web/sites/config/ipSecurityRestrictions[*]'
                    where: {
                      allOf: [
                        {
                          equals: 'Any'
                          field: 'Microsoft.Web/sites/config/ipSecurityRestrictions[*].ipAddress'
                        }
                        {
                          equals: 'Deny'
                          field: 'Microsoft.Web/sites/config/ipSecurityRestrictions[*].action'
                        }
                      ]
                    }
                  }
                  notEquals: 1
                }
              ]
            }
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
