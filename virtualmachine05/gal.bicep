targetScope = 'resourceGroup'

param name string
param param object
param location string

var tags = resourceGroup().tags

resource gal 'Microsoft.Compute/galleries@2022-03-03' = {
  name: name
  location: location
  tags: tags
  properties: {
    description: 'Private Gallery'
  }
}

resource definition 'Microsoft.Compute/galleries/images@2022-03-03' = {
  name: 'defintion01'
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
    hyperVGeneration: 'V2'
    architecture: 'x64'
    features: [
      {
        name: 'diskControllerTypes'
        value: 'SCSI'
      }
      {
        name: 'securityType'
        value: 'TrustedLaunch'
      }
    ]
  }
}

resource imageVersion 'Microsoft.Compute/galleries/images/versions@2022-03-03' existing = if(param.avd.sysprepReady) {
  name: param.avd.imageVersion
  parent: definition
}

output imageVersion string = imageVersion.id

