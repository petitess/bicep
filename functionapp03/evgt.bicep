targetScope = 'resourceGroup'

param name string
param location string = resourceGroup().location
param tags object = {}
param snetPepId string
param privateDnsZoneId string
param ipAddress string
param functionId string

resource evgt 'Microsoft.EventGrid/topics@2024-06-01-preview' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Basic'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
  }
}

resource sub 'Microsoft.EventGrid/topics/eventSubscriptions@2024-06-01-preview' = if (!empty(functionId)) {
  name: 'func-create-blob'
  parent: evgt
  properties: {
    eventDeliverySchema: 'EventGridSchema'
    retryPolicy: {
      maxDeliveryAttempts: 30
      eventTimeToLiveInMinutes: 1440
    }
    destination: {
      properties: {
        resourceId: functionId
        maxEventsPerBatch: 1
        preferredBatchSizeInKilobytes: 64
      }
      endpointType: 'AzureFunction'
    }
  }
}

resource pep 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: 'pep-${name}'
  location: location
  tags: tags
  properties: {
    customNetworkInterfaceName: 'nic-${name}'
    privateLinkServiceConnections: [
      {
        name: 'evgt'
        properties: {
          privateLinkServiceId: evgt.id
          groupIds: [
            'topic'
          ]
        }
      }
    ]
    subnet: {
      id: snetPepId
    }
    ipConfigurations: [
      {
        name: 'config'
        properties: {
          privateIPAddress: ipAddress
          groupId: 'topic'
          memberName: 'topic'
        }
      }
    ]
  }
}

resource pepDns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = {
  name: 'default'
  parent: pep
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-eventgrid-azure-net'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}
