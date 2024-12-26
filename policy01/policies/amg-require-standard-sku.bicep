targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'AMG1'
  properties: {
    displayName: 'AMG1: Azure Grafana managed instance must be deployed using the Standard Plan'
    description: 'Azure Grafana managed instance must be deployed using the Standard Plan'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'Grafana'
    }
    parameters: {
      effect: {
        allowedValues: [
          'Audit'
          'Deny'
          'Disabled'
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
            equals: 'Microsoft.Dashboard/grafana'
            field: 'type'
          }
          {
            field: 'Microsoft.Dashboard/grafana/sku.name'
            notEquals: 'Standard'
          }
        ]
      }
      then: {
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
