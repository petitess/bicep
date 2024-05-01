param name string
param location string
param tags object
param stUrl string
param computeSnetId string
param dnsRgName string
param snetPepId string
param privateEndpoints array
param adfObjectId string
param myIp string
@secure()
param sqlPass string

func insertPrefix(x string, y string) string =>
  '${substring(x, 0, length(x) - 2)}${y}-${substring(x, length(x) - 2, 2)}'

resource synw 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: name
  location: location
  tags: tags

  identity: {
    type: 'SystemAssigned'
  }

  properties: {
    defaultDataLakeStorage: {
      createManagedPrivateEndpoint: false
      accountUrl: stUrl
      filesystem: 'synw'
    }
    virtualNetworkProfile: {
      computeSubnetId: computeSnetId
    }
    managedVirtualNetwork: 'default'
    managedResourceGroupName: insertPrefix(resourceGroup().name, 'managed')
    sqlAdministratorLogin: 'sqladmin'
    sqlAdministratorLoginPassword: sqlPass
    managedVirtualNetworkSettings: {
      preventDataExfiltration: true
      allowedAadTenantIdsForLinking: [
        tenant().tenantId
      ]
    }
    publicNetworkAccess: 'Enabled'
    azureADOnlyAuthentication: false
    trustedServiceBypassEnabled: true
  }
}

resource admins 'Microsoft.Synapse/workspaces/administrators@2021-06-01' =
  if (!empty(adfObjectId)) {
    name: 'activeDirectory'
    parent: synw
    properties: {
      sid: adfObjectId
      tenantId: tenant().tenantId
    }
  }

resource sqlAdmin 'Microsoft.Synapse/workspaces/sqlAdministrators@2021-06-01' =
  if (!empty(adfObjectId)) {
    name: 'activeDirectory'
    parent: synw
    properties: {
      sid: adfObjectId
      tenantId: tenant().tenantId
    }
  }

resource allowAzure 'Microsoft.Synapse/workspaces/firewallRules@2021-06-01' = {
  parent: synw
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource allowMyIp 'Microsoft.Synapse/workspaces/firewallRules@2021-06-01' = {
  name: 'myip'
  parent: synw
  properties: {
    startIpAddress: myIp
    endIpAddress: myIp
  }
}

resource synwDb 'Microsoft.Synapse/workspaces/sqlPools@2021-06-01' = {
  name: 'sqlsynw01'
  parent: synw
  location: location
  tags: tags
  sku: {
    name: 'DW100c'
    capacity: 1
  }
  properties: {
    collation: 'SQL_LATIN1_GENERAL_CP1_CI_AS'
  }
}

resource pep 'Microsoft.Network/privateEndpoints@2023-09-01' = [
  for pep in privateEndpoints: {
    name: 'pep-${substring(name, 0, length(name) - 2)}${pep}${substring(name, length(name) - 2, 2)}'
    location: location
    tags: tags
    properties: {
      customNetworkInterfaceName: 'nic-pep-${substring(name, 0, length(name) - 2)}${pep}${substring(name, length(name) - 2, 2)}'
      privateLinkServiceConnections: [
        {
          name: '${synw.name}-${pep}'
          properties: {
            privateLinkServiceId: synw.id
            groupIds: [
              pep
            ]
          }
        }
      ]
      subnet: {
        id: snetPepId
      }
    }
  }
]

resource dns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = [
  for (dns, i) in privateEndpoints: {
    name: 'default'
    parent: pep[i]
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-${dns}-core-windows-net'
          properties: {
            privateDnsZoneId: resourceId(
              dnsRgName,
              'Microsoft.Network/privateDnsZones',
              dns == 'sqlondemand' ? 'privatelink.sql.azuresynapse.net' : 'privatelink.${dns}.azuresynapse.net'
            )
          }
        }
      ]
    }
  }
]

output principalId string = synw.identity.principalId
