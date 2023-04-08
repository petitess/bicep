targetScope = 'managementGroup'

param location string

var policyAssignments = [
  {
    name: 'Inherit-Tags-Environment'
    description: 'Inherit a tag from the subscription if missing - Environment'
    enforcementMode: 'Default'
    policyDefinitionId: '40df99da-1232-49b1-a39a-6da8d878f469'
    parameters: {
      tagName: {
        value: 'Environment'
      }
    }
  }
  {
    name: 'Inherit-Tags-Product'
    description: 'Inherit a tag from the subscription if missing - Product'
    enforcementMode: 'Default'
    policyDefinitionId: '40df99da-1232-49b1-a39a-6da8d878f469'
    parameters: {
      tagName: {
        value: 'Product'
      }
    }
  }
  {
    name: 'Inherit-Tags-CostCenter'
    description: 'Inherit a tag from the subscription if missing - CostCenter'
    enforcementMode: 'Default'
    policyDefinitionId: '40df99da-1232-49b1-a39a-6da8d878f469'
    parameters: {
      tagName: {
        value: 'CostCenter'
      }
    }
  }
  {
    name: 'Require-Tags-Environment'
    description: 'Require a tag on resource groups - Environment'
    enforcementMode: 'Default'
    policyDefinitionId: '96670d01-0a4d-4649-9c89-2d3abc0a5025'
    parameters: {
      tagName: {
        value: 'Environment'
      }
    }
  }
  {
    name: 'Require-Tags-Product'
    description: 'Require a tag on resource groups - Product'
    enforcementMode: 'Default'
    policyDefinitionId: '96670d01-0a4d-4649-9c89-2d3abc0a5025'
    parameters: {
      tagName: {
        value: 'Product'
      }
    }
  }
  {
    name: 'Require-Tags-CostCenter'
    description: 'Require a tag on resource groups - CostCenter'
    enforcementMode: 'Default'
    policyDefinitionId: '96670d01-0a4d-4649-9c89-2d3abc0a5025'
    parameters: {
      tagName: {
        value: 'CostCenter'
      }
    }
  }
  {
    name: 'Allowed-locations'
    description: 'Allowed locations'
    enforcementMode: 'Default'
    policyDefinitionId: 'e56962a6-4747-49cd-b67b-bf8b01975c4c'
    parameters: {
      listOfAllowedLocations: {
        value: [
          'global'
          'swedencentral'
          'westeurope'
          'northeurope'
          'centralus'
          'europe'
          'eastasia'
        ]
      }
    }
  }
  {
    name: 'Deny-Location-Missmatch'
    description: 'Require that the resource location matches its resource group location'
    enforcementMode: 'Default'
    policyDefinitionId: definition[0].name
    parameters: {}
  }
]

var policyDefinitions = [
  {
    name: 'Deny-Location-Missmatch'
    description: 'Require that the resource location matches its resource group location'
    mode: 'indexed'
    parameters: {}
    policyRule: {
      if: {
        field: 'location'
        notIn: [
          '[resourcegroup().location]'
          'global'
          'europe'
        ]
      }
      then: {
        effect: 'deny'
      }
    }
  }
]

resource definition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = [for definition in policyDefinitions: {
  name: 'Definition-${managementGroup().name}-${definition.name}'
  properties: {
    description: definition.description
    displayName: 'Definition-${managementGroup().name}-${definition.name}'
    mode: definition.mode
    parameters: definition.parameters
    policyRule: definition.policyRule
    policyType: 'Custom'
  }
}]

resource policy 'Microsoft.Authorization/policyAssignments@2022-06-01' = [for policy in policyAssignments: {
  name: '${take(policy.name, 15)}-${take(uniqueString(policy.description, policy.name), 8)}'
  identity: {
    type: 'SystemAssigned'
  }
  location: location
  properties: {
    description: policy.description
    displayName: 'Policy-${managementGroup().name}-${policy.name}'
    enforcementMode: policy.enforcementMode
    policyDefinitionId: contains(policy.policyDefinitionId, 'Definition') ? managementGroupResourceId('Microsoft.Authorization/policyDefinitions', policy.policyDefinitionId) : subscriptionResourceId('Microsoft.Authorization/policyDefinitions', policy.policyDefinitionId)
    parameters: policy.parameters
  }
}]
