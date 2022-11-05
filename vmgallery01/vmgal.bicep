targetScope = 'resourceGroup'

param name string
param param object
param location string
param imageversion string

var tags = resourceGroup().tags

resource gal 'Microsoft.Compute/galleries@2022-03-03' = {
  name: name
  location: location
  tags: tags
  properties: {
    description: 'Private Gallery'
  }
}

resource image 'Microsoft.Compute/galleries/images@2022-03-03' = {
  name: 'vmimage01'
  location: location
  parent: gal
  tags: tags
  properties: {
    identifier: {
      offer: 'windowsserver'  
      publisher: 'microsoftwindowsserver'
      sku: '2022-datacenter'
    }
    osState: 'Generalized'
    osType: 'Windows'
    hyperVGeneration: 'V1'
    architecture: 'x64'
    features: [
      {
        name: 'diskControllerTypes'
        value: 'SCSI'
      }
    ]
  }
}

resource vmexisting 'Microsoft.Compute/virtualMachines@2022-08-01' existing = [for (vm, i) in param.vmimage: {
  name: vm.name
  scope: resourceGroup('rg-${vm.name}')
}]

resource version 'Microsoft.Compute/galleries/images/versions@2022-03-03' = {
  name: imageversion
  location: location
  parent: image
  tags: tags
  properties: {
    storageProfile: {
      source: {
        id: vmexisting[0].id
      }
    }
    publishingProfile: {
      replicaCount: 1
      excludeFromLatest: false
      targetRegions: [
        {
          name: location
          regionalReplicaCount: 1
          storageAccountType: 'Premium_LRS'
        }
      ]
    }
  }
}

output vmid string = vmexisting[0].id
output imageid string = image.id
