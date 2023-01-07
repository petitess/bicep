targetScope = 'managementGroup'

param managementGroupName string
param location string
param policyExclusions array

var policyDefinitions = [
  {
    name: 'RequireResourceGroupTags'
    description: 'description: This policy definition enforces the existence of specified tags on resource groups.'
    policyType: 'Custom'
    mode: 'all'
    metadata: {
      category: 'Tags'
    }
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Resources/subscriptions/resourceGroups'
          }
          {
            anyOf: [
              {
                anyOf: [
                  {
                    not: {
                      field: 'tags[Environment]'
                      exists: 'true'
                    }
                  }
                  {
                    field: 'tags[Environment]'
                    match: ''
                  }
                ]
              }
              {
                anyOf: [
                  {
                    not: {
                      field: 'tags[Application]'
                      exists: 'true'
                    }
                  }
                  {
                    field: 'tags[Application]'
                    match: ''
                  }
                ]
              }
            ]
          }
        ]
      }
      then: {
        effect: 'deny'
      }
    }
  }
  {
    name: 'InheritResourceGroupTags'
    description: 'This policy definition adds the specified tags from the parent resource group when a resource is created or updated.'
    policyType: 'Custom'
    mode: 'indexed'
    metadata: {
      category: 'Tags'
    }
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'tags[Environment]'
            notEquals: '[resourceGroup().tags[\'Environment\']]'
          }
          {
            value: '[resourceGroup().tags[\'Environment\']]'
            notEquals: ''
          }
          {
            field: 'tags[Application]'
            notEquals: '[resourceGroup().tags[\'Application\']]'
          }
          {
            value: '[resourceGroup().tags[\'Application\']]'
            notEquals: ''
          }
        ]
      }
      then: {
        effect: 'modify'
        details: {
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
          ]
          operations: [
            {
              operation: 'addOrReplace'
              field: 'tags[Environment]'
              value: '[resourceGroup().tags[\'Environment\']]'
            }
            {
              operation: 'addOrReplace'
              field: 'tags[Application]'
              value: '[resourceGroup().tags[\'Application\']]'
            }
          ]
        }
      }
    }
  }
  {
    name: 'AllowedLocations'
    description: 'This policy definition enables you to restrict the locations your organization can specify when deploying resources.'
    policyType: 'Custom'
    mode: 'indexed'
    metadata: {
      category: 'Location'
    }
    parameters: {
      allowedLocations: {
        type: 'Array'
        metadata: {
          displayName: 'Allowed locations'
          description: 'The list of locations that can be specified when deploying resources.'
          strongType: 'location'
        }
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'location'
            notIn: '[parameters(\'allowedLocations\')]'
          }
          {
            field: 'location'
            notEquals: 'global'
          }
          {
            field: 'type'
            notEquals: 'Microsoft.AzureActiveDirectory/b2cDirectories'
          }
        ]
      }
      then: {
        effect: 'deny'
      }
    }
  }
  {
    name: 'DenyLocationMismatch'
    description: 'This policy definition makes sure that no resources can be placed in a different location than the parent resource group.'
    policyType: 'Custom'
    mode: 'indexed'
    metadata: {
      category: 'Location'
    }
    parameters: {}
    policyRule: {
      if: {
        field: 'location'
        notIn: [
          '[resourcegroup().location]'
          'global'
        ]
      }
      then: {
        effect: 'deny'
      }
    }
  }
]

var policyInitiative = {
  name: 'CloudAdoptionFramework'
  description: 'This policy initiative contains a set of policy definitions from the Cloud Adoption Framework.'
  policyType: 'Custom'
  metadata: {
    category: 'General'
  }
  parameters: {
    allowedLocations: {
      type: 'Array'
      metadata: {
        displayName: 'Allowed locations'
        description: 'The list of locations that can be specified when deploying resources.'
        strongType: 'location'
      }
    }
  }
}

var policyAssignment = {
  name: 'CloudAdoptionFramework'
  description: 'This assignment enforces the Cloud Adoption Framework initiative at the ManagementGroup level.'
  exclusions: []
  enforcementMode: 'Default'
  type: 'SystemAssigned'
  parameters: {
    allowedLocations: {
      value: [
        'westeurope'
        'northeurope'
        'eastus'
        'swedencentral'
      ]
    }
  }
}

resource definition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = [for policyDefinition in policyDefinitions: {
  name: 'AzurePolicyDefinition-${managementGroupName}-${policyDefinition.name}'
  properties: {
    displayName: 'AzurePolicyDefinition-${managementGroupName}-${policyDefinition.name}'
    description: policyDefinition.description
    policyType: policyDefinition.policyType
    mode: policyDefinition.mode
    metadata: policyDefinition.metadata
    parameters: policyDefinition.parameters
    policyRule: policyDefinition.policyRule
  }
}]

resource initiative 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: 'AzurePolicyInitiative-${managementGroupName}-${policyInitiative.name}'
  properties: {
    displayName: 'AzurePolicyInitiative-${managementGroupName}-${policyInitiative.name}'
    description: policyInitiative.description
    policyType: policyInitiative.policyType
    metadata: policyInitiative.metadata
    parameters: policyInitiative.parameters
    policyDefinitions: [
      {
        policyDefinitionId: '/providers/Microsoft.Management/managementGroups/${managementGroupName}/providers/Microsoft.Authorization/policyDefinitions/${definition[0].name}'
        policyDefinitionReferenceId: definition[0].name
        parameters: {}
      }
      {
        policyDefinitionId: '/providers/Microsoft.Management/managementGroups/${managementGroupName}/providers/Microsoft.Authorization/policyDefinitions/${definition[1].name}'
        policyDefinitionReferenceId: definition[1].name
        parameters: {}
      }
      {
        policyDefinitionId: '/providers/Microsoft.Management/managementGroups/${managementGroupName}/providers/Microsoft.Authorization/policyDefinitions/${definition[2].name}'
        policyDefinitionReferenceId: definition[2].name
        parameters: {
          allowedLocations: {
            value: '[parameters(\'allowedLocations\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Management/managementGroups/${managementGroupName}/providers/Microsoft.Authorization/policyDefinitions/${definition[3].name}'
        policyDefinitionReferenceId: definition[3].name
        parameters: {}
      }
    ]
  }
}

resource assignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: substring('AzurePolicyAssignment-${managementGroupName}-${policyAssignment.name}', 0, 23)
  location: location
  properties: {
    displayName: 'AzurePolicyAssignment-${managementGroupName}-${policyAssignment.name}'
    description: policyAssignment.description
    notScopes: policyExclusions
    enforcementMode: policyAssignment.enforcementMode
    policyDefinitionId: '/providers/Microsoft.Management/managementGroups/${managementGroupName}/providers/Microsoft.Authorization/policySetDefinitions/${initiative.name}'
    parameters: policyAssignment.parameters
  }
  identity: {
    type: policyAssignment.type
  }
}
