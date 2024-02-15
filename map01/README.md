```bicep
output resourceGroupsA array = union(map(resourceGroups, rg => rg.name), map(resourceGroups, rg => rg.name))
```
```json
[
    "rg-systemdev01",
    "rg-productdev01",
    "rg-monitordev01"
]
```
```bicep
output resourceGroupsB array = map(range(0, length(resourceGroups)), i => {
    id: i
    rg: resourceGroups[i].name
  })
```
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
```bicep
output resourceGroupsC array = map(fruit, a => { fruit: a })
```
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
```bicep
output mergeObjects array = map(union(resourceGroupsObject, fruitObject), a => { id: a.id, name: contains(a, 'rg') ? a.rg : a.fruit })
```
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