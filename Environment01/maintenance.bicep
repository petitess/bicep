targetScope = 'resourceGroup'

param name string
param location string

var tags = resourceGroup().tags

resource maintenance 'Microsoft.Maintenance/maintenanceConfigurations@2022-07-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    maintenanceScope: 'InGuestPatch'
    maintenanceWindow: {
      duration: '03:00'
      expirationDateTime: null
      recurEvery: '1Day' // '1Month Last Sunday' 
      startDateTime: '2022-10-16 08:00'
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

output id string = maintenance.id
output start string = maintenance.properties.maintenanceWindow.startDateTime
