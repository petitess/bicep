param name string
param location string
param tags object = resourceGroup().tags
param dbName string
param subneId string
param db_skuName string
param db_skuTier string
param db_skuCapacity int
param privateEndpointName string
param pdnszRg string

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    restrictOutboundNetworkAccess: 'Disabled'
    version: '12.0'
    administratorLogin: 'sqladmin'
    administratorLoginPassword: '1235678.abc'
    publicNetworkAccess: 'Disabled'
  }
}

resource database 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: dbName
  location: location
  properties: {
    collation:'SQL_Scandinavian_CP850_CI_AS'
  }
  sku: {
    name: db_skuName
    tier: db_skuTier
    capacity: db_skuCapacity
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-11-01' = {
  name: 'pep-${privateEndpointName}'
  location: location
  properties: {
    customNetworkInterfaceName: 'nic-${privateEndpointName}'
    subnet: {
      id: subneId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: sqlServer.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
  tags: tags

  resource privateDNSZoneGroup 'privateDnsZoneGroups@2022-09-01' = {
    name: 'default'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-database-windows-net'
          properties: {
            privateDnsZoneId: resourceId(pdnszRg, 'Microsoft.Network/privateDnsZones', 'privatelink${environment().suffixes.sqlServerHostname}')
          }
        }
      ]
    }
  }
}

output sqlServerId string = sqlServer.id
