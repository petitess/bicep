'subscription'

resource definitionAfwp 'Microsoft.Authorization/policyDefinitions@2025-01-01' = {
  name: 'AFWP1'
  properties: {
    displayName: 'AFWP1: Dont allow any source'
    description: 'Dont allow any source'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'Firewall'
    }
    parameters: {
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
        anyOf: [
          {
            count: {
              field: 'Microsoft.Network/firewallPolicies/ruleCollectionGroups/ruleCollections[*].FirewallPolicyFilterRuleCollection.rules[*]'
              where: {
                contains: '*'
                field: 'Microsoft.Network/firewallPolicies/ruleCollectionGroups/ruleCollections[*].FirewallPolicyFilterRuleCollection.rules[*].NetworkRule.sourceAddresses[*]'
              }
            }
            NotEquals: 0
          }
        ]
      }
      then: {
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
