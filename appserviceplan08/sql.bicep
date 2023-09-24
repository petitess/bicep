param name string
param location string
param snetPepId string = ''
param rgDns string

var tags = resourceGroup().tags

resource sql 'Microsoft.Sql/servers@2023-02-01-preview' = {
  name: 'sql-${name}'
  location: location
  tags: tags
  properties: {
    restrictOutboundNetworkAccess: 'Disabled'
    version: '12.0'
    administratorLogin: 'sqladmin'
    administratorLoginPassword: '1235678.abc'
    publicNetworkAccess: 'Disabled'
  }
}

resource db 'Microsoft.Sql/servers/databases@2023-02-01-preview' = {
  name: 'sqldb-${sql.name}'
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


resource pep 'Microsoft.Network/privateEndpoints@2023-05-01' = if (!empty(snetPepId)) {
  name: 'pep-${sql.name}'
  location: location
  tags: tags
  properties: {
    customNetworkInterfaceName: 'nic-${sql.name}'
    subnet: {
      id: snetPepId
    }
    privateLinkServiceConnections: [
      {
        name: sql.name
        properties: {
          privateLinkServiceId: sql.id
          groupIds: [
            'sqlserver'
          ]
        }
      }
    ]
  }
}

resource dns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = if (!empty(snetPepId)) {
  name: 'dns-${sql.name}'
  parent: pep
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config01'
        properties: {
          privateDnsZoneId: resourceId(rgDns, 'Microsoft.Network/privateDnsZones', 'privatelink${environment().suffixes.sqlServerHostname}')
        }
      }
    ]
  }
}
