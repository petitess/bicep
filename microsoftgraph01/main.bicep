targetScope = 'subscription'

provider microsoftGraph

param env string
param config object

var wellKnown = {
  MicrosoftGraph: {
    appId: '00000003-0000-0000-c000-000000000000'
    objectId: '756b4d06-16a7-4d8f-baa2-c29f29d7c0ff'
  }
}
var roles = {
  'User.Read.All': guid('User.Read.All')
}

var users = {
  admin: '94446061-65d1-4fb3-bcb9-7ba91c64e58d'
}

var gitHubOrg = 'petitess'
var gitHubRepo = 'yaml'
var subjects = {
  main: 'repo:${gitHubOrg}/${gitHubRepo}:ref:refs/heads/main'
  pull_request: 'repo:${gitHubOrg}/${gitHubRepo}:pull_request'
  dev: 'repo:${gitHubOrg}/${gitHubRepo}:environment:${env}'
}

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
}

resource role 'Microsoft.Graph/appRoleAssignedTo@v1.0' = {
  principalId: users.admin
  resourceId: sp.id
  appRoleId: roles['User.Read.All']
}
