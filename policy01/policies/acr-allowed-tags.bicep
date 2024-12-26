targetScope = 'subscription'



resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'ACR1'
  properties: {
    displayName: 'ACR1: Required Tags Container Registry'
    description: 'Required Tags Container Registry'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'Acr'
    }
    parameters: {
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
      tagName: {
        allowedValues: null
        defaultValue: 'Resource_ControlTower_Profile'
        metadata: {
          additionalProperties: null
          assignPermissions: null
          description: 'Name of the tag'
          displayName: 'Resource Profile'
          strongType: null
        }
        type: 'String'
      }
      tagSub: {
        allowedValues: null
        defaultValue: 'spoke_type'
        metadata: {
          additionalProperties: null
          assignPermissions: null
          description: 'Name of the tag'
          displayName: 'Resource Profile'
          strongType: null
        }
        type: 'String'
      }
      tagSubValue: {
        allowedValues: [
          'APPI'
        ]
        defaultValue: [
          'APPI'
        ]
        metadata: {
          additionalProperties: null
          assignPermissions: null
          description: 'The list of allowed tag'
          displayName: 'Tag Value'
          strongType: null
        }
        type: 'array'
      }
      tagValue: {
        allowedValues: [
          'APPI - Single deployment'
          'APPI - Elastic pool deployment'
        ]
        defaultValue: [
          'APPI - Single deployment'
          'APPI - Elastic pool deployment'
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
            equals: 'Microsoft.ContainerRegistry/registries'
            field: 'type'
          }
          {
            in: '''[parameters('tagSubValue')]'''
            value: '''[subscription().tags[parameters('tagSub')]]'''
          }
          {
            //field: '''[parameters('tagName')]'''
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
