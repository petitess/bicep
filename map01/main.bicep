targetScope = 'subscription'

param param object

var pathRulesArray = [for (rule, i) in param.pathRules: {
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

var resourceGroups = [
  {
    name: 'rg-systemdev01'
    x: 'a'
  }
  {
    name: 'rg-systemdev01'
    x: 'b'
  }
  {
    name: 'rg-productdev01'
    x: 'c'
  }
  {
    name: 'rg-productdev01'
    x: 'd'
  }
  {
    name: 'rg-monitordev01'
    x: 'e'
  } ]

var fruit = [
  'banan'
  'äpple'
  'apelsin'
]
var fruitObject = map(range(0, length(fruit)), i => {
    id: i
    fruit: fruit[i]
  })
var resourceGroupsObject = map(range(0, length(resourceGroups)), i => {
    id: i
    rg: resourceGroups[i].name
  })

output pathRulesArrayA array = pathRulesArray
output pathRulesArrayB array = map(pathRulesArray, rule => { name: rule.name, properties: rule.properties })
output pathRulesArrayC array = map(filter(pathRulesArray, rule => rule.site == rule.site2), rule => { name: rule.name, properties: rule.properties })
output pathRulesArrayD array = filter(pathRulesArray, rule => rule.site == rule.site2) == filter(pathRulesArray, rule => rule.site == rule.site2) ? map(pathRulesArray, rule => { name: rule.name, properties: rule.properties }) : map(pathRulesArray, rule => { name: rule.name, properties: rule.properties })

output resourceGroupsA array = union(map(resourceGroups, rg => rg.name), map(resourceGroups, rg => rg.name))
output resourceGroupsB array = map(range(0, length(resourceGroups)), i => {
    id: i
    rg: resourceGroups[i].name
  })
output resourceGroupsC array = map(fruit, a => { fruit: a })

output mergeObjects array = map(union(resourceGroupsObject, fruitObject), a => { id: a.id, name: contains(a, 'rg') ? a.rg : a.fruit })
