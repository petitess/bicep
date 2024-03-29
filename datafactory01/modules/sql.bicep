param name string
param location string
param tags object
// param env string
param rgDns string
@secure()
param username string
@secure()
param password string
param admingroupname string
param admingroupobjectid string
param peSnetId string
param firewallRules array
param dbs array

resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    administratorLogin: username
    administratorLoginPassword: password
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    administrators: {
      administratorType: 'ActiveDirectory'
      login: admingroupname
      sid: admingroupobjectid
      principalType: 'Group'
      tenantId: tenant().tenantId
    }
  }
}

resource sqlServerRules 'Microsoft.Sql/servers/firewallRules@2023-08-01-preview' = [
  for rule in firewallRules: {
    parent: sqlServer
    name: rule.name
    properties: {
      startIpAddress: rule.properties.startIpAddress
      endIpAddress: rule.properties.endIpAddress
    }
  }
]

resource pep 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: 'pep-${name}'
  location: location
  tags: tags
  properties: {
    subnet: {
      id: peSnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'pep-${name}'
        properties: {
          privateLinkServiceId: sqlServer.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
    customNetworkInterfaceName: 'nic-pep-${name}'
  }
}

resource pepgrp 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = {
  name: 'pepgrp'
  parent: pep
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-database-windows-net'
        properties: {
          privateDnsZoneId: resourceId(
            rgDns,
            'Microsoft.Network/privateDnsZones',
            'privatelink${environment().suffixes.sqlServerHostname}'
          )
        }
      }
    ]
  }
}

resource sqlDb 'Microsoft.Sql/servers/databases@2023-08-01-preview' = [
  for db in dbs: {
    name: db.name
    location: location
    tags: tags
    parent: sqlServer
    sku: {
      name: db.sku.name
      tier: db.sku.tier
      family: db.sku.family
      capacity: db.sku.capacity
    }
    properties: {
      autoPauseDelay: db.properties.autopausedelay
      availabilityZone: db.properties.availabilityzone
      zoneRedundant: db.properties.zoneredundant
      collation: db.properties.collation
    }
  }
]
