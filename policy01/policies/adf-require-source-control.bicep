targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'ADF1'
  properties: {
    displayName: 'ADF1: Enable source control on development data factories by using a Git repository'
    description: 'Enable source control on development data factories by using a Git repository'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'DataFactory'
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
          description: 'Enforce or Audit the execution of the policy'
          displayName: 'Effect'
        }
        type: 'String'
      }
      tagName: {
        defaultValue: 'environment'
        metadata: {
          description: 'Name of the tag'
          displayName: 'Resource Profile'
        }
        type: 'String'
      }
      tagValue: {
        allowedValues: [
          'prd'
          'ppr'
        ]
        defaultValue: [
          'prd'
          'ppr'
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
            equals: 'Microsoft.DataFactory/factories'
            field: 'type'
          }
          {
            field: '''[concat('tags[', parameters('tagName'), ']')]'''
            notIn: '''[parameters('tagValue')]'''
          }
          {
            anyOf: [
              {
                exists: 'false'
                field: 'Microsoft.DataFactory/factories/repoConfiguration.repositoryName'
              }
              {
                equals: ''
                field: 'Microsoft.DataFactory/factories/repoConfiguration.repositoryName'
              }
              {
                field: 'Microsoft.DataFactory/factories/repoConfiguration.type'
                notEquals: 'FactoryVSTSConfiguration'
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
