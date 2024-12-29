targetScope = 'subscription'

param idId string = ''
param location string = deployment().location

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'KV3'
  properties: {
    displayName: 'KV3: Firewall rules do not allow all network'
    description: 'Firewall rules do not allow all network'
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
                allof: [
                  {
                    field: 'Microsoft.KeyVault/vaults/publicNetworkAccess'
                    notEquals: 'Disabled'
                  }
                  {
                    Exists: 'False'
                    field: 'Microsoft.KeyVault/vaults/networkAcls'
                  }
                ]
              }
              {
                allof: [
                  {
                    field: 'Microsoft.KeyVault/vaults/publicNetworkAccess'
                    notEquals: 'Disabled'
                  }
                  {
                    equals: 'Allow'
                    field: 'Microsoft.KeyVault/vaults/networkAcls.defaultAction'
                  }
                ]
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

resource assignment 'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: 'assigment-${definition.name}'
  location: location
  properties: {
    displayName: 'assigment-${definition.properties.displayName}'
    description: definition.properties.description
    notScopes: []
    enforcementMode: 'Default'
    policyDefinitionId: definition.id
    parameters: {
      effect: {
        value: 'Deny'
      }
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${idId}': {}
    }
  }
}
