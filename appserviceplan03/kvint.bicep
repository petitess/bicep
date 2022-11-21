targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param param object
param pass string = 'A.${take(uniqueString(subscription().id), 15)}'

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
  }
}

resource secret1 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'sql-username-01'
  tags: tags
  parent: kv
  properties: {
    value: 'sqladmin'
  }
}

resource secret2 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'sql-password-01'
  tags: tags
  parent: kv
  properties: {
    value: pass
  }
}

resource secret3 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'Integration-ITGlue-ClientID'
  tags: tags
  parent: kv
  properties: {
    contentType: 'App registrations ID'
    value: param.itglueint.appclientid
  }
}

resource secret4 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'Integration-ITGlue-ClientSecret'
  tags: tags
  parent: kv
  properties: {
    contentType: 'App registrations secret'
    value: param.itglueint.appclientsecret
  }
}

resource secret5 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'ItGlueApiKey'
  tags: tags
  parent: kv
  properties: {
    value: param.itglueint.ItGlueApiKey
  }
}

resource secret6 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'ItGlueOAuthUrl'
  tags: tags
  parent: kv
  properties: {
    value: '/${subscription().subscriptionId}/oauth2/token'
  }
}

resource secret7 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'ItGlueOrgId'
  tags: tags
  parent: kv
  properties: {
    value: param.itglueint.ItGlueOrgId
  }
}

output id string = kv.id
output name string = kv.name
output kvUrl string = kv.properties.vaultUri
output pass string = pass
