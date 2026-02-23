```bicep
param topics array = [
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
      }
      {
        name: 'system-to-fim-sub'
        properties: {
          userMetadata: 'metadata for system-to-fim-sub subscription'
        }
      }
      {
        name: 'system-to-sink-sub'
        properties: {
          userMetadata: 'metadata for system-to-sink-sub subscription'
        }
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
      }
      {
        name: 'logic-to-fim-sub'
        properties: {
          userMetadata: 'metadata for logic-to-fim-sub subscription'
        }
      }
    ]
  }
]

var subObject object = toObject(topics, entry => entry.name, entry => {
  subscriptions: toObject(entry.subscriptions, subEntry => subEntry.name, subEntry => {
    properties: subEntry.properties
    name: subEntry.name
    topic: entry.name
  })
})
var topicArray array = [
  for i in items(subObject): reduce(
    items(i.value.subscriptions),
    {},
    (acc, curr) =>
      union(acc, {
        '${i.key}/${curr.key}': {
          properties: curr.value.properties
          name: curr.value.name
          topic: i.key
        }
      })
  )
]
var subArray array = items(reduce(topicArray, {}, (acc, curr) => union(acc, curr)))
output subArray array = subArray
```

```json
[
    {
        "key": "sbt-logic/logic-to-crm-sub",
        "value": {
            "properties": {
                "userMetadata": "metadata for logic-to-crm-sub subscription"
            },
            "name": "logic-to-crm-sub",
            "topic": "sbt-logic"
        }
    },
    {
        "key": "sbt-logic/logic-to-fim-sub",
        "value": {
            "properties": {
                "userMetadata": "metadata for logic-to-fim-sub subscription"
            },
            "name": "logic-to-fim-sub",
            "topic": "sbt-logic"
        }
    },
    {
        "key": "sbt-system/system-to-crm-sub",
        "value": {
            "properties": {
                "userMetadata": "metadata for system-to-crm-sub subscription"
            },
            "name": "system-to-crm-sub",
            "topic": "sbt-system"
        }
    },
    {
        "key": "sbt-system/system-to-fim-sub",
        "value": {
            "properties": {
                "userMetadata": "metadata for system-to-fim-sub subscription"
            },
            "name": "system-to-fim-sub",
            "topic": "sbt-system"
        }
    },
    {
        "key": "sbt-system/system-to-sink-sub",
        "value": {
            "properties": {
                "userMetadata": "metadata for system-to-sink-sub subscription"
            },
            "name": "system-to-sink-sub",
            "topic": "sbt-system"
        }
    }
]
```
