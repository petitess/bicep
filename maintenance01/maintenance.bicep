targetScope = 'resourceGroup'

param name string
param location string

var tags = resourceGroup().tags

resource maintenance 'Microsoft.Maintenance/maintenanceConfigurations@2021-09-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    maintenanceScope: 'InGuestPatch'
    maintenanceWindow: {
      duration: '02:00'
      expirationDateTime: null
      recurEvery: '1Month Last Sunday' //'1Day'
      startDateTime: '2022-10-15 17:16'
      timeZone: 'W. Europe Standard Time'
    }
    extensionProperties: {
      InGuestPatchMode: 'User'
    }
    installPatches: {
      linuxParameters: {
        classificationsToInclude: [
          'Critical'
          'Security'
        ]
        packageNameMasksToExclude: []
        packageNameMasksToInclude: []
      }
      windowsParameters: {
        classificationsToInclude: [
          'Critical'
          'Security'
        ]
        kbNumbersToExclude: [
          '1234567'
        ]
        kbNumbersToInclude: []
      }
      rebootSetting: 'IfRequired'
    }
  }
}


output maintenanceid string = maintenance.id
output start string = maintenance.properties.maintenanceWindow.startDateTime
