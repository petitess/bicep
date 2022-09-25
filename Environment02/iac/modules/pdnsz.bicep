targetScope = 'resourceGroup'

param filednsname string
param blobdnsname string
param tags object = resourceGroup().tags
param vnet string

resource dnsfile 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: filednsname
  location: 'global'
  tags: tags
}

resource link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'link01'
  parent: dnsfile
  location: 'global'
  tags: tags
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet
    }
  }
}

resource dnsblob 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: blobdnsname
  location: 'global'
  tags: tags
}

resource link2 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'link02'
  parent: dnsblob
  location: 'global'
  tags: tags
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet
    }
  }
}

output filednsid string = dnsfile.id
output blobdnsid string = dnsblob.id
