targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'APP1'
  properties: {
    displayName: 'APP1: App Service Basic, Standard, PremiumV2, and PremiumV3 are the only tiers authorized'
    description: 'App Service Basic, Standard, PremiumV2, and PremiumV3 are the only tiers authorized'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'AppService'
    }
    parameters: {
      effect: {
        allowedValues: [
          'Audit'
          'Deny'
        ]
        defaultValue: 'Deny'
        metadata: {
          description: 'Enforce or Audit the execution of the policy'
          displayName: 'Effect'
        }
        type: 'String'
      }
      listOfAllowedSKUs: {
        allowedValues: [
          'B1'
          'B2'
          'B3'
          'S1'
          'S2'
          'S3'
          'P0V3'
          'P1V3'
          'P2V3'
          'P3V3'
          'P1mv3'
          'P2mv3'
          'P3mv3'
          'P4mv3'
          'P5mv3'
          'P1v2'
          'P2v2'
          'P3v2'
          'EP1'
          'EP2'
          'EP3'
          'WS1'
          'WS2'
          'WS3'
        ]
        defaultValue: [
          'B1'
          'B2'
          'B3'
          'S1'
          'S2'
          'S3'
          'P0V3'
          'P1V3'
          'P2V3'
          'P3V3'
          'P1mv3'
          'P2mv3'
          'P3mv3'
          'P4mv3'
          'P5mv3'
          'P1v2'
          'P2v2'
          'P3v2'
          'EP1'
          'EP2'
          'EP3'
          'WS1'
          'WS2'
          'WS3'
        ]
        metadata: {
          additionalProperties: null
          assignPermissions: null
          description: 'The list of allowed SKU types'
          displayName: 'listOfAllowedSKUs'
          strongType: null
        }
        type: 'array'
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            equals: 'Microsoft.Web/serverFarms'
            field: 'type'
          }
          {
            field: 'Microsoft.Web/serverfarms/sku.name'
            notIn: '''[parameters('listOfAllowedSKUs')]'''
          }
        ]
      }
      then: {
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
