targetScope = 'resourceGroup'

param name string
param location string
param sku string
param kind string
param networkAcls object
param fileShares array
param containers array
param appsubnetid string

var tags = resourceGroup().tags

resource st01 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: name
  tags: tags
  location: location
  sku: {
    name:  sku
  }
  kind: kind
  properties: {
    networkAcls: {
      defaultAction: networkAcls.defaultAction
      bypass: networkAcls.bypass
      resourceAccessRules: networkAcls.ipRules
      ipRules: networkAcls.ipRules
      virtualNetworkRules: [
        {
          id: appsubnetid
          action: 'Allow'
        }
      ]
    }
  }
}

resource files 'Microsoft.Storage/storageAccounts/fileServices@2021-09-01' = {
  parent: st01
  name: 'default'
  properties: {}
}

resource shares 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-09-01' = [for fileshare in fileShares:{
  parent: files
  name: fileshare.name
  properties: fileshare.properties

}]

resource blobs 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  parent: st01
  name: 'default'
  properties: {}
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = [for container in containers: {
  parent: blobs
  name: container.name
  properties: {
  }
}]

output stid string = st01.id
