targetScope = 'resourceGroup'

param tags object = resourceGroup().tags
param vnet string

resource dns1 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.file.${environment().suffixes.storage}'
  location: 'global'
  tags: tags
}

resource link1 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'file-link'
  parent: dns1
  location: 'global'
  tags: tags
  properties: {
    registrationEnabled: false
    virtualNetwork:{
      id: vnet
    }
  }
}

resource dns2 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.blob.${environment().suffixes.storage}'
  location: 'global'
  tags: tags
}

resource link2 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'blob-link'
  parent: dns2
  location: 'global'
  tags: tags
  properties: {
    registrationEnabled: false
    virtualNetwork:{
      id: vnet
    }
  }
}

resource dns3 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.queue.${environment().suffixes.storage}'
  location: 'global'
  tags: tags
}

resource link3 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'queue-link'
  parent: dns3
  location: 'global'
  tags: tags
  properties: {
    registrationEnabled: false
    virtualNetwork:{
      id: vnet
    }
  }
}

resource dns4 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.table.${environment().suffixes.storage}'
  location: 'global'
  tags: tags
}

resource link4 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'table-link'
  parent: dns4
  location: 'global'
  tags: tags
  properties: {
    registrationEnabled: false
    virtualNetwork:{
      id: vnet
    }
  }
}

output filednsis string = dns1.id
output blobdnsid string = dns2.id
output queuednsis string = dns3.id
output tablednsid string = dns4.id
