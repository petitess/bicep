using '../main.bicep'

var roles = {
  'User.Read.All': 'df021288-bdef-4463-88db-98f22de89214'
}

param env = 'dev'

param appRegs = [
  {
    displayName: 'sp-apim-external-dev'
    owners: []
    identifierUris: [
      'api://85076d8a-e9c4-402b-a412-37476ed37dfc'
    ]
    // api: {
    //   requestedAccessTokenVersion: 2
    //   oauth2PermissionScopes: [
    //     {
    //       adminConsentDescription: 'access'
    //       adminConsentDisplayName: 'access'
    //       isEnabled: true
    //       type: 'Admin'
    //       id: '85076d8a-e9c4-402b-a412-37476ed37dfc'
    //       userConsentDescription: 'access'
    //       userConsentDisplayName: 'access'
    //       value: 'access'
    //     }
    //   ]
    // }
    appRoles: [
      // {
      //   displayName: 'User.Read.All'
      //   isEnabled: true
      //   id: roles['User.Read.All']
      //   allowedMemberTypes: [
      //     'User'
      //     'Application'
      //   ]
      //   value: 'User.Read.All'
      //   description: 'User.Read.All'
      // }
    ]
    federatedIdentityCredentials: [
      {
        name: 'github-main'
        subject: 'repo:petitess/yaml:ref:refs/heads/main'
        issuer: 'https://token.actions.githubusercontent.com'
      }
      {
        name: 'github-pr'
        subject: 'repo:petitess/yaml:pull_request'
        issuer: 'https://token.actions.githubusercontent.com'
      }
      {
        name: 'github-dev'
        subject: 'repo:petitess/yaml:environment:dev'
        issuer: 'https://token.actions.githubusercontent.com'
      }
    ]
  }
  {
    displayName: 'sp-apim-crm-dev'
    owners: [
      // 'f7f8c8eb-6bd8-4c5f-b5f6-f9a050681c3b'
    ]
    // identifierUris: [
    //   'api://285ee5a2-33f7-4fa5-95fb-03a7a2941d0c'
    // ]
    // api: {
    //   requestedAccessTokenVersion: 2
    //   oauth2PermissionScopes: [
    //     {
    //       adminConsentDescription: 'access'
    //       adminConsentDisplayName: 'access'
    //       isEnabled: true
    //       type: 'Admin'
    //       id: '285ee5a2-33f7-4fa5-95fb-03a7a2941d0c'
    //       userConsentDescription: 'access'
    //       userConsentDisplayName: 'access'
    //       value: 'access'
    //     }
    //   ]
    // }
  }
]

param managedIdentities = [
  {
    name: 'id-abc-dev-01'
    rgName: 'rg-system-dev-01'
    sqlGroup: 'grp-az-sql-app-abc-dev-01-admin'
  }
  {
    name: 'id-def-dev-01'
    rgName: 'rg-integration-dev-01'
    sqlGroup: 'grp-az-sql-app-def-dev-01-admin'
  }
]

param sqls = [
  {
    name: 'sql-app-abc-dev-01'
    rgName: 'rg-system-dev-01'
    sqlIp: '10.207.4.7'
    publicNetworkAccess: 'Enabled'
    databases: [
      {
        name: 'sqldb-app-abc-dev-01'
        sku: {
          name: 'Basic'
          capacity: 5
        }
      }
    ]
  }
  {
    name: 'sql-app-def-dev-01'
    rgName: 'rg-integration-dev-01'
    sqlIp: '10.207.4.8'
    publicNetworkAccess: 'Enabled'
    elasticPools: []
    databases: [
      {
        name: 'sqldb-def-dev-01'
        sku: {
          name: 'ElasticPool'
          capacity: 5
        }
        elasticPoolName: 'sqlep-integration-dev-01'
      }
    ]
  }
]

param pimGroups = [
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
