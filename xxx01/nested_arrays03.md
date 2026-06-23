## dev.bicepparam
```bicep
using '../main.bicep'

param pimGroups = [
  {
    name: 'grp-dev-cm1-user-PIM-DEV'
  }
  {
    name: 'grp-dev-esign-user-PIM-DEV'
  }
  {
    name: 'grp-dev-maxa-user-PIM-DEV'
  }
  {
    name: 'grp-dev-pmo-user-PIM-DEV'
    rbac: [
      {
        rgName: 'rg-asp-dev-01'
        roles: [
          'Reader'
        ]
      }
    ]
  }
  {
    name: 'grp-dev-basesystem-user-PIM-DEV'
    rbac: [
      {
        rgName: 'rg-basesystem-dev-sc-01'
        roles: [
          'Contributor'
          'KeyVaultAdministrator'
        ]
      }
      {
        rgName: 'rg-infra-app-dev-sc-01'
        roles: [
          'Reader'
        ]
      }
    ]
  }
]
```
## main.bicep 
```bicep
targetScope = 'subscription'
extension 'br:mcr.microsoft.com/bicep/extensions/microsoftgraph/v1.0:1.0.0'
#disable-diagnostics no-unused-params
#disable-diagnostics no-unused-vars

param pimGroups {
  name: string
  members: string[]?
  rbac: {
    rgName: string
    roles: string[]
  }[]?
}[]

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

resource pimGroupsR 'Microsoft.Graph/groups@v1.0' = [
  for (pim, i) in pimGroups: {
    displayName: pim.name
    mailEnabled: false
    mailNickname: pim.name
    securityEnabled: true
    uniqueName: pim.name
    owners: {
      relationships: [
        deployer().objectId
      ]
    }
    members: {
      relationships: [for (obj, i) in pim.?members ?? []: obj]
    }
  }
]
@nullIfNotFound()
resource pimGroupsE 'Microsoft.Graph/groups@v1.0' existing = [
  for (pim, i) in pimGroupsRbacArray: {
    uniqueName: pim.value.grpNameX
  }
]

module pimGroupsRbacM 'modules/rbac.bicep' = [
  for (pim, i) in pimGroupsRbacArray: {
    name: take(pim.key, 64)
    scope: resourceGroup(pim.value.rgNameX)
    params: {
      roleAssignments: [
        for r in pim.value.rolesX: {
          principalId: pimGroupsE[i].?id
          role: r
          principalType: 'Group'
        }
      ]
    }
  }
]

output pimGroupsObj object = pimGroupsObj
output pimGroupsArray array = pimGroupsArray
output pimGroupsRbacObj object = pimGroupsRbacObj
output pimGroupsRbacArray array = pimGroupsRbacArray
```
## pimGroupsObj
```json
{
    "grp-dev-pmo-user-PIM-DEV": {
        "objectX": {
            "grp-dev-pmo-user-PIM-DEV-rg-asp-dev-01": {
                "rgNameX": "rg-asp-dev-01",
                "grpNameX": "grp-dev-pmo-user-PIM-DEV",
                "rolesX": [
                    "Reader"
                ]
            }
        }
    },
    "grp-dev-basesystem-user-PIM-DEV": {
        "objectX": {
            "grp-dev-basesystem-user-PIM-DEV-rg-basesystem-dev-sc-01": {
                "rgNameX": "rg-basesystem-dev-sc-01",
                "grpNameX": "grp-dev-basesystem-user-PIM-DEV",
                "rolesX": [
                    "Contributor",
                    "KeyVaultAdministrator"
                ]
            },
            "grp-dev-basesystem-user-PIM-DEV-rg-infra-app-dev-sc-01": {
                "rgNameX": "rg-infra-app-dev-sc-01",
                "grpNameX": "grp-dev-basesystem-user-PIM-DEV",
                "rolesX": [
                    "Reader"
                ]
            }
        }
    }
}
```
## pimGroupsArray
```json
[
    {
        "grp-dev-basesystem-user-PIM-DEV-rg-basesystem-dev-sc-01": {
            "rgNameX": "rg-basesystem-dev-sc-01",
            "grpNameX": "grp-dev-basesystem-user-PIM-DEV",
            "rolesX": [
                "Contributor",
                "KeyVaultAdministrator"
            ]
        },
        "grp-dev-basesystem-user-PIM-DEV-rg-infra-app-dev-sc-01": {
            "rgNameX": "rg-infra-app-dev-sc-01",
            "grpNameX": "grp-dev-basesystem-user-PIM-DEV",
            "rolesX": [
                "Reader"
            ]
        }
    },
    {
        "grp-dev-pmo-user-PIM-DEV-rg-asp-dev-01": {
            "rgNameX": "rg-asp-dev-01",
            "grpNameX": "grp-dev-pmo-user-PIM-DEV",
            "rolesX": [
                "Reader"
            ]
        }
    }
]
```
## pimGroupsRbacObj
```json
{
    "grp-dev-basesystem-user-PIM-DEV-rg-basesystem-dev-sc-01": {
        "rgNameX": "rg-basesystem-dev-sc-01",
        "grpNameX": "grp-dev-basesystem-user-PIM-DEV",
        "rolesX": [
            "Contributor",
            "KeyVaultAdministrator"
        ]
    },
    "grp-dev-basesystem-user-PIM-DEV-rg-infra-app-dev-sc-01": {
        "rgNameX": "rg-infra-app-dev-sc-01",
        "grpNameX": "grp-dev-basesystem-user-PIM-DEV",
        "rolesX": [
            "Reader"
        ]
    },
    "grp-dev-pmo-user-PIM-DEV-rg-asp-dev-01": {
        "rgNameX": "rg-asp-dev-01",
        "grpNameX": "grp-dev-pmo-user-PIM-DEV",
        "rolesX": [
            "Reader"
        ]
    }
}
```
## pimGroupsRbacArray
```json
[
    {
        "key": "grp-dev-basesystem-user-PIM-DEV-rg-basesystem-dev-sc-01",
        "value": {
            "rgNameX": "rg-basesystem-dev-sc-01",
            "grpNameX": "grp-dev-basesystem-user-PIM-DEV",
            "rolesX": [
                "Contributor",
                "KeyVaultAdministrator"
            ]
        },
        "index": 0
    },
    {
        "key": "grp-dev-basesystem-user-PIM-DEV-rg-infra-app-dev-sc-01",
        "value": {
            "rgNameX": "rg-infra-app-dev-sc-01",
            "grpNameX": "grp-dev-basesystem-user-PIM-DEV",
            "rolesX": [
                "Reader"
            ]
        },
        "index": 1
    },
    {
        "key": "grp-dev-pmo-user-PIM-DEV-rg-asp-dev-01",
        "value": {
            "rgNameX": "rg-asp-dev-01",
            "grpNameX": "grp-dev-pmo-user-PIM-DEV",
            "rolesX": [
                "Reader"
            ]
        },
        "index": 2
    }
]
```
## rbac.bicep
```bicep 
param roleAssignments {
  principalId: string?
  role: (
    | 'Contributor'
    | 'Owner'
    | 'Reader'
    | 'KeyVaultAdministrator'
    | 'KeyVaultSecretsUser'
    | 'KeyVaultCryptoUser'
    | 'NetworkContributor'
    | 'UserAccessAdministrator'
    | 'LogAnalyticsContributor'
    | 'BackupMUAOperator'
    | 'BackupMUAAdmin'
    | 'MonitoringMetricsPublisher'
    | 'BastionReader')
  principalType: resourceInput<'Microsoft.Authorization/roleAssignments@2022-04-01'>.properties.principalType?
  description: string?
}[]

var rolesList = {
  Contributor: roleDefinitions('Contributor').id
  Owner: roleDefinitions('Owner').id
  Reader: roleDefinitions('Reader').id
  KeyVaultAdministrator: roleDefinitions('Key Vault Administrator').id
  KeyVaultSecretsUser: roleDefinitions('Key Vault Secrets User').id
  KeyVaultCryptoUser: roleDefinitions('Key Vault Crypto User').id
  NetworkContributor: roleDefinitions('Network Contributor').id
  UserAccessAdministrator: roleDefinitions('User Access Administrator').id
  LogAnalyticsContributor: roleDefinitions('Log Analytics Contributor').id
  BackupMUAOperator: roleDefinitions('Backup MUA Operator').id
  BackupMUAAdmin: roleDefinitions('Backup MUA Admin').id
  MonitoringMetricsPublisher: roleDefinitions('Monitoring Metrics Publisher').id
}

resource rbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (r, i) in roleAssignments: if (r.?principalId != null) {
    name: guid(subscription().id, r.?principalId, rolesList[r.role], resourceGroup().id)
    properties: {
      principalId: r.?principalId
      principalType: r.?principalType ?? 'ServicePrincipal'
      description: r.?description
      roleDefinitionId: rolesList[r.role]
    }
  }
]

```
