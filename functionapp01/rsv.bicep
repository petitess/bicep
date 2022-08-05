targetScope = 'resourceGroup'

param name string
param location string

var tags = resourceGroup().tags
var scheduleRunTimes = [
  '23:00:00'
]
var timeZone = 'UTC'

resource rsv 'Microsoft.RecoveryServices/vaults@2022-02-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
  properties: {}
}

resource rsvpolicy01 'Microsoft.RecoveryServices/vaults/backupPolicies@2022-02-01' = {
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

output rsvpolicy01id string = rsvpolicy01.id
output rsvname string = rsv.name
