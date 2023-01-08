targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param sku object
param scheduleRunTimes array
param retentionTimes array
param retentionDays int
param timeZone string
param daysOfTheWeek array
param retentionWeeks int

resource rsv 'Microsoft.RecoveryServices/vaults@2022-10-01' = {
  name: name
  location: location
  tags: tags
  sku: sku
  properties: {
    publicNetworkAccess: 'Enabled'
  }
}

resource defaultPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2022-09-01-preview' = {
  parent: rsv
  name: 'DefaultPolicy'
  properties: {
    instantRPDetails: {
      azureBackupRGNamePrefix: substring(resourceGroup().name, 0, length(resourceGroup().name) - 1)
    }
    backupManagementType: 'AzureIaasVM'
    schedulePolicy: {
      schedulePolicyType: 'SimpleSchedulePolicy'
      scheduleRunFrequency: 'Daily'
      scheduleRunTimes: scheduleRunTimes
      scheduleWeeklyFrequency: 0
    }
    retentionPolicy: {
      retentionPolicyType: 'LongTermRetentionPolicy'
      dailySchedule: {
        retentionTimes: retentionTimes
        retentionDuration: {
          count: retentionDays
          durationType: 'Days'
        }
      }
    }
    timeZone: timeZone
  }
}

resource weeklyPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2022-09-01-preview' = {
  parent: rsv
  name: 'WeeklyPolicy'
  properties: {
    backupManagementType: 'AzureIaasVM'
    instantRPDetails: {
      azureBackupRGNamePrefix: substring(resourceGroup().name, 0, length(resourceGroup().name) - 1)
    }
    schedulePolicy: {
      schedulePolicyType: 'SimpleSchedulePolicy'
      scheduleRunFrequency: 'Weekly'
      scheduleRunDays: [
        'Saturday'
      ]
      scheduleRunTimes: scheduleRunTimes
      scheduleWeeklyFrequency: 0
    }
    retentionPolicy: {
      retentionPolicyType: 'LongTermRetentionPolicy'
      weeklySchedule: {
        daysOfTheWeek: daysOfTheWeek
        retentionTimes: retentionTimes
        retentionDuration: {
          count: retentionWeeks
          durationType: 'Weeks'
        }
      }
      monthlySchedule: {
        retentionScheduleFormatType: 'Weekly'
        retentionScheduleWeekly: {
          daysOfTheWeek: daysOfTheWeek
          weeksOfTheMonth: [
            'Last'
          ]
        }
        retentionTimes: retentionTimes
        retentionDuration: {
          count: 1
          durationType: 'Months'
        }
      }
    }
    timeZone: timeZone
    instantRpRetentionRangeInDays: 5
  }
}

output id string = rsv.id
output name string = rsv.name
output defaultPolicy string = defaultPolicy.id
output weeklyPolicy string = weeklyPolicy.id
