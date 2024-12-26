targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'AAS5'
  properties: {
    displayName: 'AAS5: The Firewall of the service must be enabled'
    description: 'The Firewall of the service must be enabled'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'AnalysisServices'
    }
    parameters: {
      effect: {
        allowedValues: [
          'Audit'
          'Deny'
        ]
        defaultValue: 'Audit'
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
            equals: 'Microsoft.AnalysisServices/servers'
            field: 'type'
          }
          {
            anyOf: [
              {
                exists: false
                field: 'Microsoft.AnalysisServices/servers/ipV4FirewallSettings'
              }
              {
                equals: true
                value: '''[empty(field('Microsoft.AnalysisServices/servers/ipV4FirewallSettings'))]'''
              }
              {
                equals: 0
                value: '''[length(field('Microsoft.AnalysisServices/servers/ipV4FirewallSettings'))]'''
              }
              {
                exists: false
                field: 'Microsoft.AnalysisServices/servers/ipV4FirewallSettings.firewallRules'
              }
              {
                exists: false
                field: 'Microsoft.AnalysisServices/servers/ipV4FirewallSettings.enablePowerBIService'
              }
            ]
          }
        ]
      }
      then: {
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
