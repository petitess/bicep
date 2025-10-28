param name string
param location string
param diskEncryptionSetId string
param dataDisks {
  name: string
  storageAccountType: (
    | 'PremiumV2_LRS'
    | 'Premium_LRS'
    | 'Premium_ZRS'
    | 'StandardSSD_LRS'
    | 'StandardSSD_ZRS'
    | 'Standard_LRS'
    | 'UltraSSD_LRS')
  diskSizeGB: int
  createOption: 'Empty' | 'FromImage' | 'Attach'
  encryption: bool
}[]

resource disk 'Microsoft.Compute/disks@2025-01-02' = [
  for dataDisk in dataDisks: if (dataDisk.createOption == 'Empty') {
    name: '${name}-${dataDisk.name}'
    location: location
    tags: resourceGroup().tags
    sku: {
      name: dataDisk.storageAccountType
    }
    properties: {
      diskSizeGB: dataDisk.diskSizeGB
      creationData: {
        createOption: dataDisk.createOption
      }
      encryption: dataDisk.encryption
        ? {
            diskEncryptionSetId: diskEncryptionSetId
            type: 'EncryptionAtRestWithCustomerKey'
          }
        : null
    }
  }
]
