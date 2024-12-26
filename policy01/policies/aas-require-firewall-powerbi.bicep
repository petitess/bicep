targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'AAS6'
  properties: {
    displayName: 'AAS6: If the client is using PowerBI, the Firewall rules must be configured to allow all PowerBI IPs'
    description: 'If the client is using PowerBI, the Firewall rules must be configured to allow all PowerBI IPs'
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
            allOf: [
              {
                exists: true
                field: 'Microsoft.AnalysisServices/servers/ipV4FirewallSettings'
              }
              {
                field: 'Microsoft.AnalysisServices/servers/ipV4FirewallSettings.enablePowerBIService'
                notEquals: true
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
