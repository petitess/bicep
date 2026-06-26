```bicep
targetScope = 'subscription'

param param object
param jobRbac array = [
  {
    jobAgentName: 'sqlja-ElasticJobsProd'
    jobName: 'Copy_Jobs_To_JobsTest'
    principalId: '1234a90-e152-4da5-a226-3c5b2159929b'
    principalType: 'Group'
  }
  {
    jobAgentName: 'sqlja-ElasticJobsProd'
    jobName: 'Selection_Job'
    principalId: '1234a90-e152-4da5-a226-3c5b2159929b'
    principalType: 'Group'
  }
]

var jobRbacNoDuplicates = union(
  map(jobRbac, r => { principalId: r.principalId, jobAgentName: r.jobAgentName, principalType: r.?principalType }),
  map(jobRbac, r => { principalId: r.principalId, jobAgentName: r.jobAgentName, principalType: r.?principalType })
)

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
```

```bicep
output managedPeps array = filter(union(st.outputs.peps, stDl.outputs.peps), x => x.properties.privateLinkServiceConnectionState.status == 'Pending')
```
#### output: resourceGroupsA
```json
[
    "rg-systemdev01",
    "rg-productdev01",
    "rg-monitordev01"
]
```
#### output: resourceGroupsB
```json
[
    {
        "id": 0,
        "rg": "rg-systemdev01"
    },
    {
        "id": 1,
        "rg": "rg-systemdev01"
    },
    {
        "id": 2,
        "rg": "rg-productdev01"
    },
    {
        "id": 3,
        "rg": "rg-productdev01"
    },
    {
        "id": 4,
        "rg": "rg-monitordev01"
    }
]
```
#### output: resourceGroupsC
```json
[
    {
        "fruit": "banan"
    },
    {
        "fruit": "äpple"
    },
    {
        "fruit": "apelsin"
    }
]
```
#### output: mergeObjects
```json
[
    {
        "id": 0,
        "name": "rg-systemdev01"
    },
    {
        "id": 1,
        "name": "rg-systemdev01"
    },
    {
        "id": 2,
        "name": "rg-productdev01"
    },
    {
        "id": 3,
        "name": "rg-productdev01"
    },
    {
        "id": 4,
        "name": "rg-monitordev01"
    },
    {
        "id": 0,
        "name": "banan"
    },
    {
        "id": 1,
        "name": "äpple"
    },
    {
        "id": 2,
        "name": "apelsin"
    }
]
```
```bicep
var array01 = [
  {
    name: 'baba'
    nr: 1
  }
  {
    name: 'mama'
    nr: 2
  }
]

var array01WithAddedObject = [
  for z in array01: union(z, {
    whose: 'Ann\'s ${z.name}'
  })
]

output array01WithAddedObject array = array01WithAddedObject
```
#### output: array01WithAddedObject
```json
[
    {
        "name": "baba",
        "nr": 1,
        "whose": "Ann's baba"
    },
    {
        "name": "mama",
        "nr": 2,
        "whose": "Ann's mama"
    }
]
```
#### template
main.bicep
```bicep
param pimGroups array = [
  {
    name: 'grp-dev-abc-user-PIM-DEV'
  }
  {
    name: 'grp-dev-def-user-PIM-DEV'
    rbac: [
      {
        rgName: 'rg-system-dev-01'
        roles: [
          'Reader'
          'KeyVaultAdministrator'
        ]
      }
      {
        rgName: 'rg-integration-dev-01'
        roles: [
          'Contributor'
          'AzureServiceBusDataOwner'
        ]
      }
    ]
  }
]
var pimGroupsObj object = toObject(filter(pimGroups, x => x.?rbac != null), entry => entry.name, entry => {
  objectX: toObject(entry.?rbac ?? [], subEntry => '${entry.name}-${subEntry.rgName}', subEntry => {
    rgNameX: subEntry.rgName
    grpNameX: entry.name
    rolesX: subEntry.roles ?? []
  })
})
var pimGroupsArray = [for i in items(pimGroupsObj): i.?value.objectX]
var pimGroupsRbacObj = reduce(pimGroupsArray, {}, (obj1, obj2, index) => union(obj1, obj2))
var pimGroupsRbacArray array = [
  for (x, i) in items(pimGroupsRbacObj): {
    key: x.key
    value: x.value
    index: i
  }
]
output pimGroupsRbacArray array = pimGroupsRbacArray
```
#### output: pimGroupsRbacArray
```json
[
    {
        "key": "grp-dev-def-user-PIM-DEV-rg-integration-dev-01",
        "value": {
            "rgNameX": "rg-integration-dev-01",
            "grpNameX": "grp-dev-def-user-PIM-DEV",
            "rolesX": [
                "Contributor",
                "AzureServiceBusDataOwner"
            ]
        },
        "index": 0
    },
    {
        "key": "grp-dev-def-user-PIM-DEV-rg-system-dev-01",
        "value": {
            "rgNameX": "rg-system-dev-01",
            "grpNameX": "grp-dev-def-user-PIM-DEV",
            "rolesX": [
                "Reader",
                "KeyVaultAdministrator"
            ]
        },
        "index": 1
    }
]
```
