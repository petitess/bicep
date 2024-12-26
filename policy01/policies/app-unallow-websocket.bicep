targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'APP10'
  properties: {
    displayName: 'APP10: Websocket must be disabled'
    description: 'Websocket must be disabled'
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
          description: 'Enable or disable the execution of the policy'
          displayName: 'Effect'
        }
        type: 'String'
      }
      tagName: {
        allowedValues: [
          'websocket_profile'
        ]
        defaultValue: 'websocket_profile'
        metadata: {
          description: 'Name of the tag'
          displayName: 'websocket_profile'
        }
        type: 'String'
      }
      tagValue: {
        allowedValues: [
          'SignalR'
        ]
        defaultValue: 'SignalR'
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
            field: '''[concat('tags[', parameters('tagName'), ']')]'''
            notEquals: '''[parameters('tagValue')]'''
          }
        ]
      }
      then: {
        details: {
          existenceCondition: {
            equals: 'false'
            field: 'Microsoft.Web/sites/config/webSocketsEnabled'
          }
          type: 'Microsoft.Web/sites/config'
        }
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
