targetScope = 'resourceGroup'

param location string
param tags object = resourceGroup().tags
param rgstname string
param stname string
param vnetname string
param subnet string
param blob bool
param file bool
param queue bool
param table bool
param blobdnsid string
param filednsid string
param queuednsid string
param tablednsid string

resource peblob 'Microsoft.Network/privateEndpoints@2022-07-01' = if(blob) {
  name: '${stname}-blob-pe'
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: stname
        properties: {
          privateLinkServiceId: resourceId(rgstname, 'Microsoft.Storage/storageAccounts', stname)
          groupIds: [
            'blob'
          ]
        }
      }
    ]
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetname, subnet)
    }
  }
}

resource dnsblob 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-07-01' = if(blob) {
  name: 'default'
  parent: peblob
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-blob-core-windows-net'
        properties: {
          privateDnsZoneId: blobdnsid
        }
      }
    ]
  }
}


resource pefile 'Microsoft.Network/privateEndpoints@2022-07-01' = if(file) {
  name: '${stname}-file-pe'
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: stname
        properties: {
          privateLinkServiceId: resourceId(rgstname, 'Microsoft.Storage/storageAccounts', stname)
          groupIds: [
            'file'
          ]
        }
      }
    ]
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetname, subnet)
    }
  }
}

resource dnsfile 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-07-01' = if(file) {
  name: 'default'
  parent: pefile
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-file-core-windows-net'
        properties: {
          privateDnsZoneId: filednsid
        }
      }
    ]
  }
}


resource pequeues 'Microsoft.Network/privateEndpoints@2022-07-01' = if(queue) {
  name: '${stname}-queues-pe'
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: stname
        properties: {
          privateLinkServiceId: resourceId(rgstname, 'Microsoft.Storage/storageAccounts', stname)
          groupIds: [
            'queue'
          ]
        }
      }
    ]
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetname, subnet)
    }
  }
}

resource dnsqueues 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-07-01' = if(queue) {
  name: 'default'
  parent: pequeues
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-queue-core-windows-net'
        properties: {
          privateDnsZoneId: queuednsid
        }
      }
    ]
  }
}


resource petable 'Microsoft.Network/privateEndpoints@2022-07-01' = if(table) {
  name: '${stname}-table-pe'
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: stname
        properties: {
          privateLinkServiceId: resourceId(rgstname, 'Microsoft.Storage/storageAccounts', stname)
          groupIds: [
            'table'
          ]
        }
      }
    ]
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetname, subnet)
    }
  }
}

resource dnstable 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-07-01' = if(table) {
  name: 'default'
  parent: petable
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-table-core-windows-net'
        properties: {
          privateDnsZoneId: tablednsid
        }
      }
    ]
  }
}

output pefileid string = pefile.id
output pefilename string = pefile.name
output peblobid string = peblob.id
output peblobname string = peblob.name
