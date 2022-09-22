targetScope = 'resourceGroup' 

param name string
param location string

var tags = resourceGroup().tags

resource sqlsrv 'Microsoft.Sql/servers@2022-02-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    administratorLogin: 'azadmin'
    administratorLoginPassword: '12345678.abc'
    publicNetworkAccess: 'Disabled'
  }
}

resource sqldb 'Microsoft.Sql/servers/databases@2022-02-01-preview' = {
  name: name
  location: location
  tags: tags
  parent: sqlsrv
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
}

output sqlsrvid string = sqlsrv.id
