targetScope = 'resourceGroup'

param tags object = resourceGroup().tags
param vnet string

resource dns 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.file.core.windows.net'
  location: 'global'
  tags: tags
}

resource link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'file-link'
  parent: dns
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
  name: 'privatelink.blob.core.windows.net'
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

output filednsis string = dns.id
output blobdnsid string = dns2.id
