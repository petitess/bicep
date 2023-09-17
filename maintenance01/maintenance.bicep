targetScope = 'resourceGroup'

param name string
param location string
param detectionTags object
param recurEvery string

var tags = resourceGroup().tags

resource mc 'Microsoft.Maintenance/maintenanceConfigurations@2023-04-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    maintenanceScope: 'InGuestPatch'
    visibility: 'Custom'
    maintenanceWindow: {
      duration: '04:00'
      expirationDateTime: null
      recurEvery: false ? recurEvery : '1Day'
      startDateTime: '2023-09-17 15:55'
      timeZone: 'W. Europe Standard Time'
    }
    extensionProperties: {
      InGuestPatchMode: 'User'
    }
    installPatches: {
      rebootSetting: 'IfRequired'
      linuxParameters: {
        classificationsToInclude: [
          'Critical'
          'Security'
          'Other'
        ]
        packageNameMasksToExclude: []
        packageNameMasksToInclude: []
      }
      windowsParameters: {
        classificationsToInclude: [
          'Critical'
          'Security'
          'UpdateRollup'
          'FeaturePack'
          'ServicePack'
          'Definition'
          'Tools'
          'Updates'
        ]
        kbNumbersToExclude: [
          '1234567'
        ]
        kbNumbersToInclude: []
      }
    }
  }
}

module mcDynamic 'mcDynamic.bicep' = {
  scope: subscription()
  name: 'scope-${name}'
  params: {
    name: name
    mcId: mc.id
    detectionTags: detectionTags
  }
}

output id string = mc.id
