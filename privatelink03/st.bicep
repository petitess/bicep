targetScope = 'resourceGroup'

param name string
param location string
param sku string
param kind string
param networkAcls object
param fileShares array
param containers array
param queues array
param tables array

var tags = resourceGroup().tags

resource st01 'Microsoft.Storage/storageAccounts@2022-09-01' = {
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
    }
  }
}

resource filesrv 'Microsoft.Storage/storageAccounts/fileServices@2022-09-01' = {
  parent: st01
  name: 'default'
  properties: {}
}

resource shares 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-09-01' = [for fileshare in fileShares:{
  parent: filesrv
  name: fileshare.name
  properties: fileshare.properties

}]

resource blobsrv 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  parent: st01
  name: 'default'
  properties: {
    automaticSnapshotPolicyEnabled: false
    containerDeleteRetentionPolicy: {
      allowPermanentDelete: true
      days: 7
      enabled: false
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: true
      days: 7
      enabled: false
    }
    isVersioningEnabled: false
  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = [for container in containers: {
  parent: blobsrv
  name: container.name
  properties: {}
}]

resource queuesrv 'Microsoft.Storage/storageAccounts/queueServices@2022-09-01' = {
  parent: st01
  name: 'default'
  properties: {}
}

resource queue 'Microsoft.Storage/storageAccounts/queueServices/queues@2022-09-01' = [for queue in queues: {
  parent: queuesrv
  name: queue
  properties: {}
}]

resource tablesrv 'Microsoft.Storage/storageAccounts/tableServices@2022-09-01' = {
  parent: st01
  name: 'default'
  properties: {}
}

resource table 'Microsoft.Storage/storageAccounts/tableServices/tables@2022-09-01' =[for table in tables: {
  parent: tablesrv
  name: table
  properties:{}
}]

output stid string = st01.id
