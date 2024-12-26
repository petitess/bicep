targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'APP2'
  properties: {
    displayName: 'APP2: Required Tags App Service'
    description: 'Required Tags App Service'
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
        defaultValue: 'Audit'
        metadata: {
          description: 'Enforce or Audit the execution of the policy'
          displayName: 'Effect'
        }
        type: 'String'
      }
      tagName: {
        allowedValues: [
          'sg_Resource_ControlTower_Confidentiality'
        ]
        defaultValue: 'sg_Resource_ControlTower_Confidentiality'
        metadata: {
          description: 'Name of the tag'
          displayName: 'sg_Resource_ControlTower_Confidentiality'
        }
        type: 'String'
      }
      tagValue: {
        allowedValues: [
          'C0'
          'C1'
          'C2'
        ]
        defaultValue: [
          'C0'
          'C1'
          'C2'
        ]
        metadata: {
          description: 'The list of allowed tag'
          displayName: 'Tag Value'
        }
        type: 'array'
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
            field: '''[concat('tags[', parameters('tagName'), ']')]'''
            notIn: '''[parameters('tagValue')]'''
          }
        ]
      }
      then: {
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
