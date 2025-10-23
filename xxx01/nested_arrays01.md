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
# 2
```bicep
param array01 array = [
  {
    name: 'sbt01'
    subs: [
      'cm1-to-crm-sub'
      'cm1-to-fim-sub'
      'cm1-to-sink-sub'
    ]
  }
  {
    name: 'sbt02'
    subs: [
      'abc-to-def-sub'
      'abc-to-ghi-sub'
      'cm1-to-sink-sub'
    ]
  }
]

var object1 = toObject(array01, entry => entry.name, entry => entry.subs)
var loop1 = [for i in items(object1): toObject(i.value, entry => entry, entry => i.key)]
var map1 = map(loop1, arg => union(arg, arg))
var reduce1 = reduce(map1, {}, (acc, curr) => union(acc, curr))

output result object = reduce1
```
```json
{
    "cm1-to-crm-sub": "sbt01",
    "cm1-to-fim-sub": "sbt01",
    "cm1-to-sink-sub": "sbt02",
    "abc-to-def-sub": "sbt02",
    "abc-to-ghi-sub": "sbt02"
}
```
