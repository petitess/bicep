targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'APP5'
  properties: {
    displayName: 'APP5: The app must use a certificate stored in a Key Vault'
    description: 'The app must use a certificate stored in a Key Vault'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'AppService'
    }
    parameters:  {
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
          existenceCondition: {
            exists: 'true'
            field: 'Microsoft.Web/certificates/keyVaultId'
          }
          type: 'Microsoft.Web/certificates'
        }
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
