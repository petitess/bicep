targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'APP3'
  properties: {
    displayName: 'APP3: Azure Defender must be enabled for C2 handling App Service'
    description: 'Azure Defender must be enabled for C2 handling App Service'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'AppService'
    }
    parameters: {
      effect: {
        allowedValues: [
          'AuditIfNotExists'
          'Disabled'
        ]
        defaultValue: 'AuditIfNotExists'
        metadata: {
          description: 'Activate or deactivate the execution of the policy'
          displayName: 'Effect'
        }
        type: 'String'
      }
      tagName: {
        allowedValues: [
          'Resource_ControlTower_Confidentiality'
        ]
        defaultValue: 'Resource_ControlTower_Confidentiality'
        metadata: {
          description: 'Name of the tag'
          displayName: 'Resource_ControlTower_Confidentiality'
        }
        type: 'String'
      }
      tagValue: {
        allowedValues: [
          'C2'
        ]
        defaultValue: 'C2'
        metadata: {
          description: 'The list of allowed tag'
          displayName: 'Tag Value'
        }
        type: 'string'
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
          {
            equals: '''[parameters('tagValue')]'''
            field: '''[concat('tags[', parameters('tagName'), ']')]'''
          }
        ]
      }
      then: {
        details: {
          existenceCondition: {
            equals: 'Standard'
            field: 'Microsoft.Security/pricings/pricingTier'
          }
          existenceScope: 'subscription'
          name: 'AppServices'
          type: 'Microsoft.Security/pricings'
        }
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
