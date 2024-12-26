targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'RES3'
  properties: {
    displayName: 'RES3: Role assignment must be done through an Azure AD group (no direct user assignment).'
    description: 'Role assignment must be done through an Azure AD group (no direct user assignment).'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'RBAC'
    }
    parameters: {
      denyType: {
        allowedValues: [
          'user'
        ]
        defaultValue: [
          'user'
        ]
        metadata: {
          description: 'The list of built-in roles Id to deny assignment of'
          displayName: 'Forbidden built-in roles'
        }
        type: 'array'
      }
      effect: {
        allowedValues: [
          'Audit'
          'Deny'
        ]
        defaultValue: 'Audit'
        metadata: {
          description: 'Activate or deactivate the execution of the policy'
          displayName: 'Effect'
        }
        type: 'String'
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            equals: 'Microsoft.Authorization/roleAssignments'
            field: 'type'
          }
          {
            field: 'Microsoft.Authorization/roleAssignments/principalType'
            in: '''[parameters('denyType')]'''
          }
        ]
      }
      then: {
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
