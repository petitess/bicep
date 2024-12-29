targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param sku object
param scheduleRunTimes array
param retentionTimes array
param timeZone string
param snetId string
param dnsRgName string

resource rsv 'Microsoft.RecoveryServices/vaults@2024-10-01' = {
  name: name
  location: location
  tags: tags
  sku: sku
  properties: {
    publicNetworkAccess: 'Enabled'
    securitySettings: {
      immutabilitySettings: {
        state: 'Unlocked'
      }
      softDeleteSettings: {
        softDeleteRetentionPeriodInDays: 14
        softDeleteState: 'Enabled'
      }
    }
    restoreSettings: {
      crossSubscriptionRestoreSettings: {
        crossSubscriptionRestoreState: 'Enabled'
      }
    }
  }
}

resource defaultPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2024-10-01' = {
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
          count: 30
          durationType: 'Days'
        }
      }
    }
    tieringPolicy: {
      ArchivedRP: {
        tieringMode: 'DoNotTier'
        duration: 0
        durationType: 'Invalid'
      }
    }
    instantRpRetentionRangeInDays: 2
    timeZone: timeZone
  }
}

resource PolicyFileServer 'Microsoft.RecoveryServices/vaults/backupPolicies@2024-10-01' = {
  parent: rsv
  name: 'Policy-FileServer01'
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
          count: 14
          durationType: 'Days'
        }
      }
    }
    instantRpRetentionRangeInDays: 2
    timeZone: timeZone
  }
}

resource filesharePolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2024-10-01' = {
  name: 'FileSharePolicy01'
  parent: rsv
  location: location
  tags: tags
  properties: {
    backupManagementType: 'AzureStorage'
    retentionPolicy: {
      retentionPolicyType: 'LongTermRetentionPolicy'
      dailySchedule: {
        retentionTimes: scheduleRunTimes
        retentionDuration: {
          count: 14
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
        retentionScheduleFormatType: 'Weekly'
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
          count: 3
          durationType: 'Months'
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

resource pep 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: 'pep-${name}'
  location: location
  tags: tags
  properties: {
    customNetworkInterfaceName: 'nic-${name}'
    privateLinkServiceConnections: [
      {
        name: name
        properties: {
          privateLinkServiceId: rsv.id
          groupIds: [
            'AzureBackup'
          ]
        }
      }
    ]
    subnet: {
      id: snetId
    }
  }
}

resource dns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = {
  name: 'default'
  parent: pep
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-sdc-backup-windowsazure-com'
        properties: {
          privateDnsZoneId: resourceId(dnsRgName, 'Microsoft.Network/privateDnsZones', 'privatelink.sdc.backup.windowsazure.com')
        }
      }
      {
        name: 'privatelink-queue-core-windows-net'
        properties: {
          privateDnsZoneId: resourceId(dnsRgName, 'Microsoft.Network/privateDnsZones', 'privatelink.queue.${environment().suffixes.storage}')
        }
      }
      {
        name: 'privatelink-blob-core-windows-net'
        properties: {
          privateDnsZoneId: resourceId(dnsRgName, 'Microsoft.Network/privateDnsZones', 'privatelink.blob.${environment().suffixes.storage}')
        }
      }
    ]
  }
}

output id string = rsv.id
output name string = rsv.name
output defaultPolicy string = defaultPolicy.id
output filesharePolicy string = filesharePolicy.id
output PolicyFileServer string = PolicyFileServer.id
