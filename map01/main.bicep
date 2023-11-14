targetScope = 'subscription'

param param object

var pathRulesArray = [for (rule, i) in param.value.pathRules: {
  name: 'path-${rule.name}'
  site: rule.site
  site2: rule.site2
  properties: {
    paths: rule.paths
    backendAddressPool: {
      id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', 'name', 'pool-${rule.site}-${rule.name}')
    }
    backendHttpSettings: {
      id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', 'name', 'settings-${rule.site}-${rule.name}')
    }
    rewriteRuleSet: contains(rule, 'rewriteRuleSet') ? {
      id: resourceId('Microsoft.Network/applicationGateways/rewriteRuleSets', 'name', 'rewrite-${rule.site}-${rule.name}')
    } : null
    firewallPolicy: null
  }
}]

output x array = pathRulesArray

output z array = map(pathRulesArray, rule => {name: rule.name, properties: rule.properties})

output c array = map(filter(pathRulesArray, rule => rule.site == rule.site2), rule => {name: rule.name, properties: rule.properties})

output d array = filter(pathRulesArray, rule => rule.site == rule.site2) == filter(pathRulesArray, rule => rule.site == rule.site2) ? map(pathRulesArray, rule => {name: rule.name, properties: rule.properties}) : map(pathRulesArray, rule => {name: rule.name, properties: rule.properties})

