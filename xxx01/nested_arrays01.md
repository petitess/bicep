# 1
```bicep
param array01 array = [
  {
    object01: {
      'cm1-to-crm-sub': 'sbt-cm1-updates-dev-sc-01'
      'cm1-to-fim-sub': 'sbt-cm1-updates-dev-sc-01'
      'cm1-to-sink-sub': 'sbt-cm1-updates-dev-sc-01'
      'maxa-to-crm-sub': 'sbt-maxa-events-dev-sc-01'
      'maxa-to-sink-sub': 'sbt-maxa-events-dev-sc-01'
    }
  }
]

var loop = [for (a, i) in array01: a.object01 ]

var object01toObject = loop[0]

output result object = object01toObject
```
#### Result
```json
{
    "cm1-to-crm-sub": "sbt-cm1-updates-dev-sc-01",
    "cm1-to-fim-sub": "sbt-cm1-updates-dev-sc-01",
    "cm1-to-sink-sub": "sbt-cm1-updates-dev-sc-01",
    "maxa-to-crm-sub": "sbt-maxa-events-dev-sc-01",
    "maxa-to-sink-sub": "sbt-maxa-events-dev-sc-01"
}
```
