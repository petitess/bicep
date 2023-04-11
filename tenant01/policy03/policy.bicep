targetScope = 'managementGroup'

param location string

var policyAssignments = [
  {
    name: 'ISO-27001-2013'
    description: 'The International Organization for Standardization (ISO) 27001 standard provides requirements for establishing, implementing, maintaining, and continuously improving an Information Security Management System (ISMS). These policies address a subset of ISO 27001:2013 controls. Additional policies will be added in upcoming releases. For more information, visit https://aka.ms/iso27001-init'
    enforcementMode: 'Default'
    policySetDefinitionId: '89c6cddc-1c73-4ac1-b19c-54d1a15a42f2'
    parameters: {}
  }
]

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
    policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policySetDefinitions', policy.policySetDefinitionId)
    parameters: policy.parameters
  }
}]
