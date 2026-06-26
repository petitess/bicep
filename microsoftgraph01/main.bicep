targetScope = 'subscription'
// https://mcr.microsoft.com/artifact/mar/bicep/extensions/microsoftgraph/v1.0/tags
extension 'br:mcr.microsoft.com/bicep/extensions/microsoftgraph/v1.0:1.0.0'

param env string
param location string = 'swedencentral'
param managedIdentities {
  name: string
  sqlGroup: string?
  rgName: string
  federatedIdentityCredentials: {
    name: string
    subject: string
    issuer: string?
  }[]?
}[] = []
param sqls {
  name: string
  rgName: string
  publicNetworkAccess: 'Enabled' | 'Disabled'
  sqlIp: string
  azureADOnlyAuthentication: bool?
  databases: {
    name: string
    collation: 'Finnish_Swedish_CI_AS'?
    @description('Name of an elastic pool. Sku should be: ElasticPool')
    elasticPoolName: string?
    sku: {
      name: 'GP_Gen5_2' | 'BC_Gen5_2' | 'Basic' | 'Standard' | 'Premium' | 'ElasticPool'
      tier: string?
      capacity: int
    }
  }[]?
  elasticPools: {
    name: string
    sku: {
      name: 'GP_Gen5' | 'HS_Gen5' | 'BC_Gen5' | 'BasicPool' | 'StandardPool' | 'PremiumPool'
    }
  }[]?
}[]
param pimGroups {
  name: string
  members: string[]?
  rbac: {
    rgName: string
    roles: (
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
      | 'AzureServiceBusDataOwner'
      | 'AppConfigurationDataOwner'
      | 'StorageBlobDataContributor')[]
  }[]?
}[]
param appRegs {
  displayName: string
  identifierUris: string[]?
  owners: string[]?
  requiredResourceAccess: {
    resourceAppId: '00000003-0000-0000-c000-000000000000'
    resourceAccess: {
      @maxLength(36)
      @minLength(36)
      id: string
      type: 'Role'
    }[]
  }[]?
  api: {
    requestedAccessTokenVersion: 2
    oauth2PermissionScopes: {
      adminConsentDescription: string
      adminConsentDisplayName: string
      isEnabled: true
      type: 'Admin' | 'User'
      id: string
      userConsentDescription: string
      userConsentDisplayName: string
      value: string
    }[]
  }?
  appRoles: {
    displayName: string
    isEnabled: bool
    id: string
    allowedMemberTypes: ('User' | 'Application')[]
    value: string
    description: string
  }[]?
  web: {
    redirectUris: string[]?
    implicitGrantSettings: {
      enableAccessTokenIssuance: bool
      enableIdTokenIssuance: bool
    }
  }?
  federatedIdentityCredentials: {
    name: string
    subject: string?
    issuer: string
  }[]?
}[] = []
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

var appRegsObj object = toObject(
  filter(appRegs, x => x.?federatedIdentityCredentials != null),
  entry => entry.displayName,
  entry => {
    objectX: toObject(
      entry.?federatedIdentityCredentials ?? [],
      subEntry => '${entry.displayName}-${subEntry.name}',
      subEntry => {
        displayNameX: entry.displayName
        nameX: subEntry.name
        subjectX: subEntry.subject
        issuerX: subEntry.issuer
      }
    )
  }
)
var appRegsArray = [for i in items(appRegsObj): i.?value.objectX]
var fedCredsObj = reduce(appRegsArray, {}, (obj1, obj2, index) => union(obj1, obj2))
var fedCredsArray array = [
  for (x, i) in items(fedCredsObj): {
    key: x.key
    value: x.value
    index: i
  }
]

var wellKnown = {
  MicrosoftGraph: {
    appId: '00000003-0000-0000-c000-000000000000'
  }
}
//(Invoke-GraphRequest -Uri "/v1.0/servicePrincipals?`$filter=appId eq '00000003-0000-0000-c000-000000000000'").value.appRoles | Where-Object { $_.value -eq "User.Read.All" }
var roles = {
  'User.Read.All': 'df021288-bdef-4463-88db-98f22de89214'
}

resource microsoftGraph 'Microsoft.Graph/servicePrincipals@v1.0' existing = {
  appId: wellKnown.MicrosoftGraph.appId
}

output id string = microsoftGraph.id

resource rgSys 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-system-${env}-01'
  location: location
}

resource rgInt 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-integration-${env}-01'
  location: location
}
@description('Application.ReadWrite.OwnedBy, Application.ReadWrite.All')
resource appReg 'Microsoft.Graph/applications@v1.0' = [
  for a in appRegs: {
    displayName: a.displayName
    uniqueName: a.displayName
    owners: {
      relationships: a.?owners ?? [deployer().objectId]
    }
    identifierUris: a.?identifierUris ?? []
    api: a.?api ?? {}
    requiredResourceAccess: a.?requiredResourceAccess ?? []
    appRoles: a.?appRoles ?? []
    web: a.?web
  }
]

resource sp 'Microsoft.Graph/servicePrincipals@v1.0' = [
  for (a, i) in appRegs: {
    appId: appReg[i].appId
    owners: {
      relationships: a.?owners ?? [deployer().objectId]
    }
  }
]

@batchSize(1)
resource fed 'Microsoft.Graph/applications/federatedIdentityCredentials@v1.0' = [
  for cred in fedCredsArray: {
    name: '${cred.value.displayNameX}/${cred.value.nameX}'
    audiences: [
      'api://AzureADTokenExchange'
    ]
    issuer: cred.value.issuerX
    subject: cred.value.subjectX
  }
]

@description('AppRoleAssignment.ReadWrite.All')
resource role 'Microsoft.Graph/appRoleAssignedTo@v1.0' = [
  for (a, i) in appRegs: {
    principalId: sp[i].id
    resourceId: microsoftGraph.id
    appRoleId: roles['User.Read.All']
  }
]

@description('DelegatedPermissionGrant.ReadWrite.All	')
resource oauth2 'Microsoft.Graph/oauth2PermissionGrants@v1.0' = [
  for (a, i) in appRegs: {
    clientId: sp[i].id
    consentType: 'AllPrincipals'
    principalId: null
    resourceId: microsoftGraph.id
    scope: 'DataProtection.Read.All'
  }
]

module idM 'id.bicep' = [
  for i in managedIdentities: {
    scope: resourceGroup(i.rgName)
    params: {
      name: i.name
      location: location
      federatedIdentityCredentials: i.?federatedIdentityCredentials
    }
  }
]
@description('Group.ReadWrite.All')
resource sqlGroups 'Microsoft.Graph/groups@v1.0' = [
  for (sql, i) in sqls: {
    displayName: toLower('grp-az-${sql.name}-admin')
    mailEnabled: false
    mailNickname: toLower('grp-az-${sql.name}-admin')
    securityEnabled: true
    uniqueName: toLower('grp-az-${sql.name}-admin')
    dependsOn: [idM]
    members: {
      relationships: [
        for (obj, i) in filter(managedIdentities, x => x.?sqlGroup == 'grp-az-${sql.name}-admin'): reference(
          resourceId(
            subscription().subscriptionId,
            obj.rgName,
            'Microsoft.ManagedIdentity/userAssignedIdentities',
            obj.name
          ),
          '2025-05-31-preview',
          'Full'
        ).properties.principalId
      ]
      // relationships: [
      //   for (obj, i) in filter(union(functionApp, apps), x => x.?sqlGroup == 'grp-az-${sql.name}-admin'): reference(
      //     resourceId(subscription().subscriptionId, obj.rgName, 'Microsoft.Web/sites', obj.name),
      //     '2026-03-15',
      //     'Full'
      //   ).identity.principalId
      // ]
    }
  }
]
@batchSize(1)
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

module pimGroupsE 'groupsE.bicep' = [
  for (pim, i) in pimGroupsRbacArray: {
    name: take('ex-${pim.key}', 64)
    dependsOn: [pimGroupsR]
    params: {
      groupName: pim.value.grpNameX
    }
  }
]

module pimGroupsRbacM 'rbac.bicep' = [
  for (pim, i) in pimGroupsRbacArray: {
    name: take('rbac-${pim.key}', 64)
    scope: resourceGroup(pim.value.rgNameX)
    params: {
      roleAssignments: [
        for r in pim.value.rolesX: {
          principalId: pimGroupsE[i].outputs.objectId
          role: r
          principalType: 'Group'
        }
      ]
    }
  }
]
