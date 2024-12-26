targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'KV2'
  properties: {
    displayName: 'KV2: Soft delete must be enabled on Key Vault'
    description: 'Soft delete must be enabled on Key Vault'
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
            anyOf: [
              {
                exists: 'false'
                field: 'Microsoft.KeyVault/vaults/enableSoftDelete'
              }
              {
                equals: 'false'
                field: 'Microsoft.KeyVault/vaults/enableSoftDelete'
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
