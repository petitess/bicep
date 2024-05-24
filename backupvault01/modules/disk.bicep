param name string
param location string = resourceGroup().location
param vaultName string
param backup bool
param policyId string
param vaultRgName string

resource disk 'Microsoft.Compute/disks@2023-10-02' = {
  name: name
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    creationData: {
      createOption: 'Empty'
    }
    diskSizeGB: 10
  }
}

module backupInstance 'bvault-instance.bicep' = if(backup) {
  name: name
  scope: resourceGroup(vaultRgName)
  params: {
    name: name
    datasourceType: 'Microsoft.Compute/disks'
    resourceId: disk.id
    resourceType: 'Microsoft.Compute/disks'
    vaultName: vaultName
    policyId: policyId
  }
}
