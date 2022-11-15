targetScope = 'resourceGroup'

param env string
param location string

var tags = resourceGroup().tags

resource sql 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: 'sql-b3care-${env}-01'
  location: location
  tags: union(tags,{
    admins: 'grp-b3care-operations'
  })
  properties: {
    restrictOutboundNetworkAccess: 'Disabled'
    version: '12.0'
    administrators: {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: true
      login: 'grp-b3care-operations'
      sid: '09cf7cc4-7e5d-4c75-96f4-4667c4a4f4fd'
      tenantId: subscription().tenantId
    }

  }
}

resource db1 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  name: 'sqldb-${env}-01'
  location: location
  tags: tags
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
