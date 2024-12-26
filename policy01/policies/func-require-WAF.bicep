targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'FUNC2'
  properties: {
    displayName: 'FUNC2: Publicly HTTPS exposed Functions must use the WAF'
    description: 'Publicly HTTPS exposed Functions must use the WAF'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'Function'
    }
    parameters: {
      WAFIPs: {
        allowedValues: [
          '1.83.128.0/21'
          '1.143.32.0/19'
          '1.126.72.0/21'

        ]
        defaultValue: [
          '1.83.128.0/21'
          '1.143.32.0/19'
          '1.126.72.0/21'
        ]
        metadata: {
          description: 'The list of WAF IPs addresses'
          displayName: 'WAF IPs'
        }
        type: 'array'
      }
      appProfileValues: {
        allowedValues: [
          'public'
        ]
        defaultValue: 'public'
        metadata: {
          description: 'The list of resource profile tags involved in this policy'
          displayName: 'Resource profile tag value'
        }
        type: 'string'
      }
      effect: {
        allowedValues: [
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
      tagAppProfile: {
        defaultValue: 'Resource_ControlTower_Profile'
        metadata: {
          description: 'Resource profile tag'
          displayName: 'Resource_ControlTower_Profile'
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
          {
            equals: '''[parameters('appProfileValues')]'''
            field: '''[concat('tags[', parameters('tagAppProfile'), ']')]'''
          }
          {
            anyOf: [
              {
                exists: 'false'
                field: 'Microsoft.Web/sites/publicNetworkAccess'
              }
              {
                field: 'Microsoft.Web/sites/publicNetworkAccess'
                notEquals: 'Disabled'
              }
            ]
          }
        ]
      }
      then: {
        details: {
          existenceCondition: {
            allOf: [
              {
                count: {
                  field: 'Microsoft.Web/sites/config/IpSecurityRestrictions[*]'
                  where: {
                    allOf: [
                      {
                        field: 'Microsoft.Web/sites/config/IpSecurityRestrictions[*].ipAddress'
                        notEquals: 'Any'
                      }
                      {
                        Equals: 0
                        count: {
                          name: 'WAFIPs'
                          value: '''[parameters('WAFIPs')]'''
                          where: {
                            Equals: true
                            value: '''[ipRangeContains(current('WAFIPs'), current('Microsoft.Web/sites/config/IpSecurityRestrictions[*].ipAddress'))]'''
                          }
                        }
                      }
                      {
                        equals: 'Allow'
                        field: 'Microsoft.Web/sites/config/IpSecurityRestrictions[*].action'
                      }
                    ]
                  }
                }
                equals: 0
              }
              {
                equals: 'Deny'
                field: 'Microsoft.Web/sites/config/IpSecurityRestrictionsDefaultAction'
              }
            ]
          }
          type: 'Microsoft.Web/sites/config'
        }
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
