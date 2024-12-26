targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'APP7'
  properties: {
    displayName: 'APP7: SCM network firewall must allow only access from authorized IP adresses'
    description: 'SCM network firewall must allow only access from authorized IP adresses'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'AppService'
    }
    parameters: {
      effect: {
        allowedValues: [
          'DeployIfNotExists'
          'Disabled'
        ]
        defaultValue: 'DeployIfNotExists'
        metadata: {
          description: 'Activate or deactivate the execution of the policy'
          displayName: 'Effect'
        }
        type: 'String'
      }
      whiteListSCMIPs: {
        allowedValues: [
          '1.234.1.0/24'
          '89.167.1.0/24'
          '154.113.1.0/24'
          '211.144.1.0/24'
          '8.25.1.0/24'
        ]
        defaultValue: [
          '1.234.1.0/24'
          '89.167.1.0/24'
          '154.113.1.0/24'
          '211.144.1.0/24'
          '8.25.1.0/24'
        ]
        metadata: {
          description: 'The list of whitelisted IPs addresses'
          displayName: 'whitelisted IPs addresses'
        }
        type: 'array'
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
                      scmIpSecurityRestrictions: [
                        {
                          action: 'Allow'
                          description: 'Allow from WAF Imperva Ips'
                          ipAddress: '192.109.140.0/24'
                          name: 'Allow from BlueCoat IP 1'
                          priority: 120
                        }
                        {
                          action: 'Allow'
                          description: 'Allow from WAF Imperva Ips'
                          ipAddress: '192.109.141.0/24'
                          name: 'Allow from BlueCoat IP 2'
                          priority: 200
                        }
                        {
                          action: 'Allow'
                          description: 'Allow from WAF Imperva Ips'
                          ipAddress: '192.109.143.0/24'
                          name: 'Allow from BlueCoat IP 3'
                          priority: 300
                        }
                        {
                          action: 'Allow'
                          description: 'Allow from WAF Imperva Ips'
                          ipAddress: '192.109.144.0/24'
                          name: 'Allow from BlueCoat IP 4'
                          priority: 400
                        }
                        {
                          action: 'Allow'
                          description: 'Allow from WAF Imperva Ips'
                          ipAddress: '192.109.145.0/24'
                          name: 'Allow from BlueCoat IP 5'
                          priority: 500
                        }
                        {
                          action: 'Allow'
                          description: 'Allow from WAF Imperva Ips'
                          ipAddress: '192.109.146.0/24'
                          name: 'Allow from BlueCoat IP 6'
                          priority: 600
                        }
                        {
                          action: 'Allow'
                          description: 'Allow from WAF Imperva Ips'
                          ipAddress: '192.109.147.0/24'
                          name: 'Allow from BlueCoat IP 7'
                          priority: 700
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
                    field: 'Microsoft.Web/sites/config/scmIpSecurityRestrictions[*]'
                    where: {
                      allOf: [
                        {
                          field: 'Microsoft.Web/sites/config/scmIpSecurityRestrictions[*].ipAddress'
                          notIn: '''[parameters('whiteListSCMIPs')]'''
                        }
                        {
                          equals: 'Allow'
                          field: 'Microsoft.Web/sites/config/scmIpSecurityRestrictions[*].action'
                        }
                      ]
                    }
                  }
                  notEquals: 0
                }
                {
                  count: {
                    field: 'Microsoft.Web/sites/config/scmIpSecurityRestrictions[*]'
                    where: {
                      allOf: [
                        {
                          equals: 'Any'
                          field: 'Microsoft.Web/sites/config/scmIpSecurityRestrictions[*].ipAddress'
                        }
                        {
                          equals: 'Deny'
                          field: 'Microsoft.Web/sites/config/scmIpSecurityRestrictions[*].action'
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
