targetScope = 'subscription'

// https://mcr.microsoft.com/artifact/mar/bicep/extensions/microsoftgraph/v1.0/tags
extension 'br:mcr.microsoft.com/bicep/extensions/microsoftgraph/v1.0:0.2.0-preview'

param env string
param config object

var wellKnown = {
  MicrosoftGraph: {
    appId: '00000003-0000-0000-c000-000000000000'
  }
}
var roles = {
  'User.Read.All': 'df021288-bdef-4463-88db-98f22de89214'
}

var users = {
  admin: deployer().objectId
}

var gitHubOrg = 'petitess'
var gitHubRepo = 'yaml'
var subjects = {
  main: 'repo:${gitHubOrg}/${gitHubRepo}:ref:refs/heads/main'
  pull_request: 'repo:${gitHubOrg}/${gitHubRepo}:pull_request'
  dev: 'repo:${gitHubOrg}/${gitHubRepo}:environment:${env}'
}

resource microsoftGraph 'Microsoft.Graph/servicePrincipals@v1.0' existing = {
  appId: wellKnown.MicrosoftGraph.appId
}

output id string = microsoftGraph.id

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-prod-${env}-bicep-01'
  location: 'swedencentral'
}

resource entraGroupContributor 'Microsoft.Graph/groups@v1.0' = {
  displayName: 'sec-${resourceGroup.name}-contributor'
  mailEnabled: false
  mailNickname: 'sec-${resourceGroup.name}-contributor'
  securityEnabled: true
  uniqueName: 'sec-${resourceGroup.name}-contributor'
}

resource appReg 'Microsoft.Graph/applications@v1.0' = {
  displayName: 'app-bicep-${env}-01'
  uniqueName: 'app-bicep-${env}-01'
  owners: {
    relationships: [
      deployer().objectId
    ]
  }
  requiredResourceAccess: [
    {
      resourceAppId: wellKnown.MicrosoftGraph.appId
      resourceAccess: [
        {
          id: roles['User.Read.All']
          type: 'Role'
        }
      ]
    }
  ]
  // identifierUris: [
  //   'https://api.xcloud.onmicrosoft.com'
  // ]

  web: {
    redirectUris: [
      'https://portal-api.comp.com/.auth/login/aad/callback'
    ]
    implicitGrantSettings: {
      enableAccessTokenIssuance: false
      enableIdTokenIssuance: true
    }
  }
  appRoles: [
    {
      displayName: 'User.Read.All'
      isEnabled: true
      id: roles['User.Read.All']
      allowedMemberTypes: [
        'User'
        'Application'
      ]
      value: 'User.Read.All'
      description: 'User.Read.All'
    }
  ]
}

resource fed 'Microsoft.Graph/applications/federatedIdentityCredentials@v1.0' = [
  for subject in items(subjects): {
    name: '${appReg.uniqueName}/${subject.key}'
    audiences: [
      'api://AzureADTokenExchange'
    ]
    issuer: 'https://token.actions.githubusercontent.com'
    subject: subject.value
  }
]

resource sp 'Microsoft.Graph/servicePrincipals@v1.0' = {
  appId: appReg.appId

  owners: {
    relationships: [
      deployer().objectId
    ]
  }
}

resource role 'Microsoft.Graph/appRoleAssignedTo@v1.0' = {
  principalId: users.admin
  resourceId: sp.id
  appRoleId: roles['User.Read.All']
}

output spId string = sp.id

resource oauth2 'Microsoft.Graph/oauth2PermissionGrants@v1.0' = {
  clientId: sp.id
  consentType: 'AllPrincipals'
  principalId: null
  resourceId: microsoftGraph.id
  scope: 'DataProtection.Read.All'
}
