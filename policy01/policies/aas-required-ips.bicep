targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'AAS2'
  properties: {
    displayName: 'AAS2: The Firewall must whitelist IPs for users connecting through the Public Endpoint'
    description: ''
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'AnalysisServices'
    }
    parameters: {
      ZScalerIP: {
        allowedValues: [
          '27.251.211.1/32'
          '216.218.133.0/26'
          '64.74.126.0/26'
          '216.52.207.0/26'
        ]
        defaultValue: [
          '27.251.211.1/32'
          '216.218.133.0/26'
          '64.74.126.0/26'
          '216.52.207.0/26'
        ]
        metadata: {
          description: 'The list of ZScaler IP addresses ranges'
          displayName: 'ZScaler IPs'
        }
        type: 'array'
      }
      effect: {
        allowedValues: [
          'Audit'
          'Deny'
        ]
        defaultValue: 'Audit'
        metadata: {
          additionalProperties: null
          assignPermissions: null
          description: 'Activate or deactivate the execution of the policy'
          displayName: 'Effect'
          strongType: null
        }
        type: 'String'
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            equals: 'Microsoft.AnalysisServices/servers'
            field: 'type'
          }
          {
            count: {
              field: 'Microsoft.AnalysisServices/servers/ipV4FirewallSettings.firewallRules[*]'
            }
            notEquals: 0
          }
          {
            count: {
              field: 'Microsoft.AnalysisServices/servers/ipV4FirewallSettings.firewallRules[*]'
              where: {
                count: {
                  name: 'ZScalerIPs'
                  value: '''[parameters('ZScalerIP')]'''
                  where: {
                    allOf: [
                      {
                        equals: true
                        value: '''[ipRangeContains(current('ZScalerIPs'), first(field('Microsoft.AnalysisServices/servers/ipV4FirewallSettings.firewallRules[*].rangeStart')))'''
                      }
                      {
                        equals: true
                        value: '''[ipRangeContains(current('ZScalerIPs'), first(field('Microsoft.AnalysisServices/servers/ipV4FirewallSettings.firewallRules[*].rangeEnd')))]'''
                      }
                    ]
                  }
                }
                equals: 1
              }
            }
            notEquals: '''[length(field('Microsoft.AnalysisServices/servers/ipV4FirewallSettings.firewallRules[*]'))]'''
          }
        ]
      }
      then: {
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
