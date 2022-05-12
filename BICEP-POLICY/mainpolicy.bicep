targetScope = 'subscription' 

resource policy 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: 'Test-Bicep'
  properties: {
     displayName: 'Test-Bicep-policy'
     enforcementMode: 'Default'
     policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/cccc23c7-8427-4f53-ad12-b6a63eb452b3'
     parameters: {
      listOfAllowedSKUs: {
        value: [
          'standard_b2ms'
          'standard_b1ms'
          'standard_b4ms'

        ]

      }
     }
  }
}

