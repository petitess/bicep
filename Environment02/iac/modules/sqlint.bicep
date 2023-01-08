targetScope = 'resourceGroup'

param env string
param location string
@secure()
param sqlpassword string
param groupsid string
param groupname string
param kvname string

var tags = resourceGroup().tags

resource sql 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: 'sql-itglue-${env}-01'
  location: location
  tags: union(tags, {
      admins: groupname
    })
  properties: {
    restrictOutboundNetworkAccess: 'Disabled'
    version: '12.0'
    administratorLogin: 'sqladmin'
    administratorLoginPassword: sqlpassword
    administrators: {
      principalType: 'Group'
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: false
      login: groupname
      sid: groupsid
      tenantId: subscription().tenantId
    }

  }
}

resource db1 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  name: 'sqldb-${env}-01'
  location: location
  tags: union(tags, {
      admins: groupname
    })
  parent: sql
  sku: {
    name: 'Basic'
    tier: 'Basic'
    size: '5'
  }
  properties: {
    collation: 'Finnish_Swedish_CI_AS'
  }
}

resource enc 'Microsoft.Sql/servers/databases/transparentDataEncryption@2022-05-01-preview' = {
  name: 'current'
  parent: db1
  properties: {
    state: 'Enabled'
  }
}

resource kvexisting 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: kvname
}

resource secret8 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'sqlCS'
  tags: tags
  parent: kvexisting
  properties: {
    contentType: 'DB connection string'
    value: 'Server=tcp:${sql.name}${environment().suffixes.sqlServerHostname},1433;Initial Catalog=${db1.name};Persist Security Info=False;User ID=sqladmin;Password=${sqlpassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
  }
}
