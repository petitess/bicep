param name string
param location string
param tags object = resourceGroup().tags
param ruleGroupOverrides array = []
param customRules array = []

resource waf 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2022-09-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    policySettings: {
      state: 'Enabled'
      mode: 'Prevention'
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.2'
          ruleGroupOverrides: ruleGroupOverrides
        }
      ]
    }
    customRules: customRules
  }
}

output id string = waf.id
