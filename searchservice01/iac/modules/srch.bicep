param name string
param location string
param skuName string
param environment string
param pdnszRg string
param sqlResourceId string
param tags object = resourceGroup().tags
param subnetId string

var privateEndpointName = 'standards-standard-srch-${environment}-01'

resource searchService 'Microsoft.Search/searchServices@2023-11-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: skuName
  }
  properties: {
    partitionCount: 1
    replicaCount: 1
    publicNetworkAccess: 'disabled'
  }
}

resource sharedPrivateLink 'Microsoft.Search/searchServices/sharedPrivateLinkResources@2023-11-01' = {
  name: 'pl-${privateEndpointName}'
  parent: searchService
  properties: {
    groupId: 'sqlServer'
    privateLinkResourceId: sqlResourceId
    provisioningState: 'Succeeded'
    requestMessage: 'Need shared private link to connect data source from sql server'
    status: 'Approved'
  }
}

resource privateEndpointSearch 'Microsoft.Network/privateEndpoints@2023-06-01' = {
  name: 'pep-${privateEndpointName}'
  location: location
  properties: {
    customNetworkInterfaceName: 'nic-${privateEndpointName}'
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: searchService.id
          groupIds: [
            'searchService'
          ]
        }
      }
    ]
  }
  tags: tags

  resource privateDNSZoneGroup 'privateDnsZoneGroups' = {
    name: 'default-srch'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-search-windows-net'
          properties: {
            privateDnsZoneId: resourceId(pdnszRg, 'Microsoft.Network/privateDnsZones', 'privatelink.search.windows.net') //pdnszSearch.id
          }
        }
      ]
    }
  }
}

output principalId string = searchService.identity.principalId
