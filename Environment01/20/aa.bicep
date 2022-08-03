targetScope = 'resourceGroup'

param name string
param location string
param updateSchedules array

resource aa 'Microsoft.Automation/automationAccounts@2021-06-22' = {
  name: name
  tags: resourceGroup().tags
  location: location
  properties: {
    sku: {
      name: 'Basic'
    }
    encryption: {
      keySource: 'Microsoft.Automation'
      identity: {}
    }
  }
}

resource updatemgmt 'Microsoft.Automation/automationAccounts/softwareUpdateConfigurations@2019-06-01'  = [for updateSchedule in updateSchedules: {
  name: 'Win_${updateSchedule.name}'
  parent: aa
  properties: {
    scheduleInfo: {
      startTime: updateSchedule.startTime
      interval: 1
      frequency: 'Month'
      timeZone: 'Europe/Stockholm'
      isEnabled: true
      advancedSchedule: {
        monthlyOccurrences: [
          {
            day: updateSchedule.day
            occurrence: updateSchedule.occurrence
          }
        ]
      }
    }
    updateConfiguration: {
      operatingSystem: 'Windows'
      windows: {
        includedUpdateClassifications: updateSchedule.includedUpdateClassifications
        rebootSetting: 'IfRequired'
        excludedKbNumbers: []
        includedKbNumbers: []
      }
      targets: {
        azureQueries: [
          {
            scope: [
              subscription().id
            ]
            tagSettings: {
              tags: {
                UpdateManagement: [
                  updateSchedule.name
                ]
              }
              filterOperator: 'All'
            }
            locations: []
          }
        ]
        
      }
    }
  }
}]

resource updateManagementLinux 'Microsoft.Automation/automationAccounts/softwareUpdateConfigurations@2019-06-01' = [for updateSchedule in updateSchedules: {
  parent: aa
  name: 'Linux-${updateSchedule.name}'
  properties: {
    scheduleInfo: {
      startTime: updateSchedule.startTime
      interval: 1
      frequency: 'Month'
      timeZone: 'Europe/Stockholm'
      isEnabled: true
      advancedSchedule: {
        monthlyOccurrences: [
          {
            day: updateSchedule.day
            occurrence: 2
          }
        ]
      }
    }
    updateConfiguration: {
      operatingSystem: 'Linux'
      linux: {
        includedPackageClassifications: 'Security'
        rebootSetting: 'RebootOnly'
      }
      targets: {
        azureQueries: [
          {
            scope: [
              subscription().id
            ]
            tagSettings: {
              tags: {
                UpdateManagement: [
                  updateSchedule.name
                ]
              }
              filterOperator: 'All'
            }
            locations: []
          }
        ]
      }
      duration: 'PT2H'
    }
  }
}]

output aaName string = aa.name
output aaId string = aa.id
