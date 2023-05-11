param name string
param location string
param tags object = resourceGroup().tags

var scheduleRunTimes = [
  '23:00:00'
]

resource rsv 'Microsoft.RecoveryServices/vaults@2023-02-01' = {
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

resource policyFile 'Microsoft.RecoveryServices/vaults/backupPolicies@2023-02-01' = {
  name: 'policy-fileshare01'
  location: location
  tags: tags
  parent: rsv
  properties: {
    backupManagementType: 'AzureStorage'
    workLoadType: 'AzureFileShare'
    timeZone: 'W. Europe Standard Time'
    retentionPolicy: {
      retentionPolicyType: 'LongTermRetentionPolicy'
      dailySchedule: {
        retentionDuration: {
          count: 30
          durationType: 'Days'
        }
        retentionTimes: scheduleRunTimes
      }
    }
    schedulePolicy: {
      schedulePolicyType: 'SimpleSchedulePolicy'
      scheduleRunFrequency: 'Daily'
      scheduleRunTimes: scheduleRunTimes
      scheduleRunDays: [
        'Monday'
        'Tuesday'
        'Wednesday'
      ]
    }
  }
}

output name string = rsv.name
output filesharePolicy string = policyFile.id
