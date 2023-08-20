targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param sku object
param scheduleRunTimes array
param retentionDays int

var timeZone = 'UTC'

resource rsv 'Microsoft.RecoveryServices/vaults@2023-04-01' = {
  name: name
  location: location
  tags: tags
  sku: sku
  properties: {
    publicNetworkAccess: 'Enabled'
  }
}

resource defaultPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2023-04-01' = {
  name: 'DefaultPolicy01'
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
        retentionDuration: {
          count: retentionDays
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

output id string = rsv.id
output name string = rsv.name
output defaultPolicy string = defaultPolicy.id
