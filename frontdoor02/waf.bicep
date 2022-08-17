targetScope = 'resourceGroup'

param name string

var tags = resourceGroup().tags

resource waf 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2020-11-01' = {
  name: replace(name, '-', '')
  location: 'global'
  tags: tags
  sku: {
    name: 'Classic_AzureFrontDoor'
  }
  properties: {
    policySettings: {
      customBlockResponseStatusCode: 403
      enabledState: 'Enabled'
      mode: 'Detection'
      requestBodyCheck: 'Disabled'
      redirectUrl: 'https://www.google.com/'
    }
    customRules: {
      rules:[
         {
          name: 'AllowUSA'
          ruleType: 'RateLimitRule'
          action:  'Allow'
          enabledState: 'Enabled'
          rateLimitDurationInMinutes: 1
          rateLimitThreshold: 100
          priority: 100
          matchConditions:  [
            {
              operator: 'GeoMatch'
              matchVariable: 'RemoteAddr'
              matchValue:  [
                'US'
              ] 
            }
          ]
         }
         {
          name: 'DenyCountries'
          action: 'Redirect'
          enabledState: 'Enabled'
          ruleType: 'MatchRule'
          rateLimitDurationInMinutes: 1
          rateLimitThreshold: 100
          priority: 200
          matchConditions: [
            {
              matchVariable: 'RemoteAddr'
              operator: 'GeoMatch'
              negateCondition: false
              matchValue: [
                'AF'
                'RU'
                'KH'
              ]
            }
          ]
        }
      ]
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'Microsoft_DefaultRuleSet'  
          ruleSetVersion: '1.1'  
        }
      ]
    }
  }
}

output wafid string = waf.id
