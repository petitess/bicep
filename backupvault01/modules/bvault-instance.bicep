param name string
param resourceId string
param vaultName string
param policyId string
param containersList array = []
param datasourceType 'Microsoft.Storage/storageAccounts/blobServices' | 'Microsoft.Compute/disks'
param resourceType 'Microsoft.Storage/storageAccounts' | 'Microsoft.Compute/disks'

resource vaultedBlobItem 'Microsoft.DataProtection/backupVaults/backupInstances@2024-04-01' = {
  name: '${vaultName}/${name}'
  properties: {
    friendlyName: name
    identityDetails: {
      useSystemAssignedIdentity: true
    }
    objectType: 'BackupInstance'
    dataSourceInfo: {
      resourceID: resourceId
      resourceLocation: resourceGroup().location
      datasourceType: datasourceType
      resourceName: name
      objectType: 'Datasource'
      resourceType: resourceType
    }
    dataSourceSetInfo: {
      resourceID: resourceId
      resourceLocation: resourceGroup().location
      datasourceType: datasourceType
      resourceName: name
      objectType: 'DatasourceSet'
      resourceType: resourceType
    }
    policyInfo: {
      policyId: policyId
      policyParameters: datasourceType == 'Microsoft.Storage/storageAccounts/blobServices'
        ? {
            backupDatasourceParametersList: [
              {
                objectType: 'BlobBackupDatasourceParameters'
                containersList: containersList
              }
            ]
          }
        : datasourceType == 'Microsoft.Compute/disks'
            ? {
                dataStoreParametersList: [
                  {
                    objectType: 'AzureOperationalStoreParameters'
                    dataStoreType: 'OperationalStore'
                    resourceGroupId: resourceGroup().id
                  }
                ]
              }
            : null
    }
  }
}
