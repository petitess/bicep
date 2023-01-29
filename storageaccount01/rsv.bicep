targetScope = 'resourceGroup'

param name string
param location string

var tags = resourceGroup().tags
var scheduleRunTimes = [
  '23:00:00'
]
var timeZone = 'UTC'

resource rsv 'Microsoft.RecoveryServices/vaults@2022-10-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
  }
}

resource rsvpolicy01 'Microsoft.RecoveryServices/vaults/backupPolicies@2022-09-01-preview' = {
  name:  'rsvbac02'
  parent: rsv
  location: location
  tags: tags
  properties: {

    backupManagementType: 'AzureIaasVM'
    policyType: 'V1'
    instantRpRetentionRangeInDays: 1
    retentionPolicy: {
      retentionPolicyType: 'LongTermRetentionPolicy'
      dailySchedule: {
        retentionTimes: scheduleRunTimes
        retentionDuration:{
          count: 7
          durationType: 'Days'
        }
      }
    }
    schedulePolicy: {
      schedulePolicyType: 'SimpleSchedulePolicy'
      scheduleRunFrequency: 'Daily'
       scheduleRunDays: [
        'Friday'
       ]
         scheduleRunTimes: scheduleRunTimes
      }
      timeZone: timeZone
    }
  }

  resource rsvpolicy02 'Microsoft.RecoveryServices/vaults/backupPolicies@2022-09-01-preview' = {
    name:  'FileSharePolicy01'
    parent: rsv
    location: location
    tags: tags
    properties: {
      backupManagementType: 'AzureStorage'
      retentionPolicy: {
        retentionPolicyType: 'LongTermRetentionPolicy'
        dailySchedule: {
          retentionTimes: scheduleRunTimes
          retentionDuration:{
            count: 30
            durationType: 'Days'
          }
        }
        weeklySchedule: {
          daysOfTheWeek: [
             'Thursday'
          ]
          retentionTimes: scheduleRunTimes
          retentionDuration: {
            count: 5
            durationType: 'Weeks'
          }
        }
        monthlySchedule: {
          retentionScheduleFormatType:  'Weekly'
          retentionScheduleWeekly: {
            daysOfTheWeek: [
              'Friday'
            ]
            weeksOfTheMonth: [
              'First'
            ]
          }
          retentionTimes: scheduleRunTimes
          retentionDuration: {
            count: 5
            durationType: 'Months'
          }
        }
        yearlySchedule: {
          retentionScheduleFormatType: 'Weekly'
          monthsOfYear: [
            'January'
          ]
          retentionScheduleWeekly: {
            daysOfTheWeek: [
              'Wednesday'
            ]
            weeksOfTheMonth: [
               'Second'
            ]
          }
          retentionTimes: scheduleRunTimes
          retentionDuration:  {
            count: 1
            durationType: 'Years'
          }
        }
      }
      schedulePolicy: {
        schedulePolicyType: 'SimpleSchedulePolicy'
        scheduleRunFrequency: 'Daily'
         scheduleRunDays: [
          'Monday'
          'Tuesday'
          'Wednesday'
          'Thursday'
          'Friday'
          'Saturday'
          'Sunday'
         ]
           scheduleRunTimes: scheduleRunTimes
        }
        timeZone: timeZone
        workLoadType: 'AzureFileShare'
      }
    }


output rsvpolicy01id string = rsvpolicy01.id
output rsvname string = rsv.name
output rsvid string = rsv.id
output filesharepolicyid string = rsvpolicy02.id
