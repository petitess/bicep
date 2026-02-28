### Nested arrays
```bicep
var topics = [
  {
    name: 'sbt-system'
    properties: {
      userMetadata: 'metadata for sbt-system topic'
    }
    subscriptions: [
      {
        name: 'system-to-crm-sub'
        properties: {
          userMetadata: 'metadata for system-to-crm-sub subscription'
        }
        rules: [
          {
            filterType: 'CorrelationFilter'
            correlationFilter: {
              properties: {
                weekday: 'lördag'
              }
            }
          }
          {
            filterType: 'SqlFilter'
            sqlFilter: {
              sqlExpression: '[property-name] = \'value\''
            }
          }
        ]
      }
      {
        name: 'system-to-fim-sub'
        properties: {
          userMetadata: 'metadata for system-to-fim-sub subscription'
        }
        rules: [
          {
            filterType: 'CorrelationFilter'
            correlationFilter: {
              properties: {
                weekday: 'fredag'
              }
            }
          }
        ]
      }
      {
        name: 'system-to-sink-sub'
        properties: {
          userMetadata: 'metadata for system-to-sink-sub subscription'
        }
        rules: [
          {
            filterType: 'CorrelationFilter'
            correlationFilter: {
              properties: {
                weekday: 'torsdag'
              }
            }
          }
        ]
      }
    ]
  }
  {
    name: 'sbt-logic'
    properties: {
      userMetadata: 'metadata for sbt-logic topic'
    }
    subscriptions: [
      {
        name: 'logic-to-crm-sub'
        properties: {
          userMetadata: 'metadata for logic-to-crm-sub subscription'
        }
        rules: []
      }
      {
        name: 'logic-to-fim-sub'
        properties: {
          userMetadata: 'metadata for logic-to-fim-sub subscription'
        }
        rules: []
      }
      {
        name: 'logic-to-sink-sub'
        properties: {
          userMetadata: 'metadata for logic-to-sink-sub subscription'
        }
        rules: []
      }
    ]
  }
]
```
### Create subscription array
```bicep
@description('Subscriptions transformed to an array of objects')
var subscriptionsObject object = toObject(topics, entry => entry.name, entry => {
  subscriptions: toObject(entry.subscriptions, subEntry => subEntry.name, subEntry => {
    properties: subEntry.properties
    name: subEntry.name
    topic: entry.name
    rules: subEntry.rules ?? []
  })
})
var topicArray array = [
  for i in items(subscriptionsObject): reduce(
    items(i.value.subscriptions),
    {},
    (acc, curr) =>
      union(acc, {
        '${i.key}/${curr.key}': {
          properties: curr.value.properties
          name: curr.value.name
          topic: i.key
          rules: curr.value.rules
        }
      })
  )
]
var subscriptionsArray array = items(reduce(topicArray, {}, (acc, curr) => union(acc, curr)))

output subscriptionsObject object = subscriptionsObject
output topicArray array = topicArray
output subscriptionsArray array = subscriptionsArray
```
### Create rule array
```bicep
@description('Rules transformed to an array of objects')
var rulesObject object = toObject(subscriptionsArray, entry => entry.key, entry => entry.value.rules)
var topicRulesArray array = [
  for (r, i) in items(rulesObject): reduce(
    r.value,
    {},
    (acc, curr) =>
      union(acc, {
        '${r.key}/${curr.filterType}_${i}': curr
      })
  )
]
var rulesArray array = items(reduce(topicRulesArray, {}, (acc, curr) => union(acc, curr)))

output rulesObject object = rulesObject
output topicRulesArray array = topicRulesArray
output rulesArray array = rulesArray
```
### Subscriptions output
```json
{
    "sbt-system": {
        "subscriptions": {
            "system-to-crm-sub": {
                "properties": {
                    "userMetadata": "metadata for system-to-crm-sub subscription"
                },
                "name": "system-to-crm-sub",
                "topic": "sbt-system",
                "rules": [
                    {
                        "filterType": "CorrelationFilter",
                        "correlationFilter": {
                            "properties": {
                                "weekday": "lördag"
                            }
                        }
                    },
                    {
                        "filterType": "SqlFilter",
                        "sqlFilter": {
                            "sqlExpression": "[property-name] = 'value'"
                        }
                    }
                ]
            },
            "system-to-fim-sub": {
                "properties": {
                    "userMetadata": "metadata for system-to-fim-sub subscription"
                },
                "name": "system-to-fim-sub",
                "topic": "sbt-system",
                "rules": [
                    {
                        "filterType": "CorrelationFilter",
                        "correlationFilter": {
                            "properties": {
                                "weekday": "fredag"
                            }
                        }
                    }
                ]
            },
            "system-to-sink-sub": {
                "properties": {
                    "userMetadata": "metadata for system-to-sink-sub subscription"
                },
                "name": "system-to-sink-sub",
                "topic": "sbt-system",
                "rules": [
                    {
                        "filterType": "CorrelationFilter",
                        "correlationFilter": {
                            "properties": {
                                "weekday": "torsdag"
                            }
                        }
                    }
                ]
            }
        }
    },
    "sbt-logic": {
        "subscriptions": {
            "logic-to-crm-sub": {
                "properties": {
                    "userMetadata": "metadata for logic-to-crm-sub subscription"
                },
                "name": "logic-to-crm-sub",
                "topic": "sbt-logic",
                "rules": []
            },
            "logic-to-fim-sub": {
                "properties": {
                    "userMetadata": "metadata for logic-to-fim-sub subscription"
                },
                "name": "logic-to-fim-sub",
                "topic": "sbt-logic",
                "rules": []
            },
            "logic-to-sink-sub": {
                "properties": {
                    "userMetadata": "metadata for logic-to-sink-sub subscription"
                },
                "name": "logic-to-sink-sub",
                "topic": "sbt-logic",
                "rules": []
            }
        }
    }
}
```
### Rules output
```json
[
    {
        "key": "sbt-system/system-to-crm-sub/CorrelationFilter_3",
        "value": {
            "filterType": "CorrelationFilter",
            "correlationFilter": {
                "properties": {
                    "weekday": "lördag"
                }
            }
        }
    },
    {
        "key": "sbt-system/system-to-crm-sub/SqlFilter_3",
        "value": {
            "filterType": "SqlFilter",
            "sqlFilter": {
                "sqlExpression": "[property-name] = 'value'"
            }
        }
    },
    {
        "key": "sbt-system/system-to-fim-sub/CorrelationFilter_4",
        "value": {
            "filterType": "CorrelationFilter",
            "correlationFilter": {
                "properties": {
                    "weekday": "fredag"
                }
            }
        }
    },
    {
        "key": "sbt-system/system-to-sink-sub/CorrelationFilter_5",
        "value": {
            "filterType": "CorrelationFilter",
            "correlationFilter": {
                "properties": {
                    "weekday": "torsdag"
                }
            }
        }
    }
]
```
