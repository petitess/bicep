targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'KV4'
  properties: {
    displayName: 'KV4: Azure Key Vault public access must be disabled'
    description: 'Azure Key Vault public access must be disabled'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'KeyVault'
    }
    parameters: {
      effect: {
        allowedValues: [
          'Audit'
          'Deny'
        ]
        defaultValue: 'Audit'
        metadata: {
          description: 'Enforce or Audit the execution of the policy'
          displayName: 'Effect'
        }
        type: 'String'
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            equals: 'Microsoft.KeyVault/vaults'
            field: 'type'
          }
          {
            field: 'Microsoft.Keyvault/vaults/createMode'
            notEquals: 'recover'
          }
          {
            field: 'Microsoft.KeyVault/vaults/publicNetworkAccess'
            notEquals: 'Disabled'
          }
        ]
      }
      then: {
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
