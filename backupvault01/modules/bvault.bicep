param name string
param redundancy 'LocallyRedundant' | 'GeoRedundant' | 'ZoneRedundant' = 'LocallyRedundant'
param location string = resourceGroup().location
param tags object = resourceGroup().tags
param softDelete bool = false
param immutability bool = false
param logAnalyticsWorkspaceId string = ''

resource bvault 'Microsoft.DataProtection/backupVaults@2024-04-01' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    featureSettings: {
      // crossRegionRestoreSettings: redundancy == 'GeoRedundant'
      //   ? {
      //       state: 'Enabled'
      //     }
      //   : null
      crossSubscriptionRestoreSettings: {
        state: 'Enabled'
      }
    }
    monitoringSettings: {
      azureMonitorAlertSettings: {
        alertsForAllJobFailures: 'Disabled'
      }
    }
    securitySettings: {
      softDeleteSettings: {
        state: softDelete ? 'On' : 'Off'
        retentionDurationInDays: 14
      }
      immutabilitySettings: immutability
        ? {
            state: 'Enabled'
          }
        : null
    }
    storageSettings: [
      {
        datastoreType: 'VaultStore'
        type: redundancy
      }
    ]
  }
}

resource operationalPolicyBlob 'Microsoft.DataProtection/backupVaults/backupPolicies@2024-04-01' = if (false) {
  name: 'policy-operational-blob'
  parent: bvault
  properties: {
    datasourceTypes: [
      'Microsoft.Storage/storageAccounts/blobServices'
    ]
    objectType: 'BackupPolicy'
    policyRules: [
      {
        name: 'Default'
        objectType: 'AzureRetentionRule'
        isDefault: true
        lifecycles: [
          {
            deleteAfter: {
              duration: 'P7D'
              objectType: 'AbsoluteDeleteOption'
            }
            sourceDataStore: {
              dataStoreType: 'OperationalStore'
              objectType: 'DataStoreInfoBase'
            }
          }
        ]
      }
    ]
  }
}

resource vaultedPolicyBlob 'Microsoft.DataProtection/backupVaults/backupPolicies@2024-04-01' = if (false) {
  name: 'policy-vaulted-blob'
  parent: bvault
  properties: {
    objectType: 'BackupPolicy'
    datasourceTypes: [
      'Microsoft.Storage/storageAccounts/blobServices'
    ]
    policyRules: [
      {
        isDefault: true
        name: 'Default'
        objectType: 'AzureRetentionRule'
        lifecycles: [
          {
            targetDataStoreCopySettings: []
            deleteAfter: {
              objectType: 'AbsoluteDeleteOption'
              duration: 'P7D'
            }
            sourceDataStore: {
              dataStoreType: 'VaultStore'
              objectType: 'DataStoreInfoBase'
            }
          }
        ]
      }
      {
        name: 'BackupDaily'
        objectType: 'AzureBackupRule'
        backupParameters: {
          backupType: 'Discrete'
          objectType: 'AzureBackupParams'
        }
        dataStore: {
          dataStoreType: 'VaultStore'
          objectType: 'DataStoreInfoBase'
        }
        trigger: {
          objectType: 'ScheduleBasedTriggerContext'
          schedule: {
            timeZone: 'UTC'
            repeatingTimeIntervals: [
              'R/2024-05-23T21:00:00+01:00/P1D'
            ]
          }
          taggingCriteria: [
            {
              isDefault: true
              taggingPriority: 99
              tagInfo: {
                tagName: 'Default'
              }
            }
          ]
        }
      }
    ]
  }
}

resource policyDisk 'Microsoft.DataProtection/backupVaults/backupPolicies@2024-04-01' = if (false) {
  name: 'policy-disk'
  parent: bvault
  properties: {
    datasourceTypes: [
      'Microsoft.Compute/disks'
    ]
    objectType: 'BackupPolicy'
    policyRules: [
      {
        isDefault: true
        lifecycles: [
          {
            deleteAfter: {
              duration: 'P7D'
              objectType: 'AbsoluteDeleteOption'
            }
            sourceDataStore: {
              dataStoreType: 'OperationalStore'
              objectType: 'DataStoreInfoBase'
            }
            targetDataStoreCopySettings: []
          }
        ]
        name: 'Default'
        objectType: 'AzureRetentionRule'
      }
      {
        backupParameters: {
          backupType: 'Incremental'
          objectType: 'AzureBackupParams'
        }
        dataStore: {
          dataStoreType: 'OperationalStore'
          objectType: 'DataStoreInfoBase'
        }
        name: 'BackupDaily'
        objectType: 'AzureBackupRule'
        trigger: {
          objectType: 'ScheduleBasedTriggerContext'
          schedule: {
            repeatingTimeIntervals: [
              'R/2024-05-24T21:00:00+01:00/P1D'
            ]
            timeZone: 'W. Europe Standard Time'
          }
          taggingCriteria: [
            {
              isDefault: true
              tagInfo: {
                tagName: 'Default'
              }
              taggingPriority: 99
            }
          ]
        }
      }
    ]
  }
}

resource diagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  scope: bvault
  name: 'diag-bvault'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'AzureBackupReport'
        enabled: true
      }
      {
        category: 'AzureSiteRecoveryJobs'
        enabled: true
      }
      {
        category: 'AzureSiteRecoveryEvents'
        enabled: true
      }
      {
        category: 'AzureSiteRecoveryReplicatedItems'
        enabled: true
      }
      {
        category: 'AzureSiteRecoveryReplicationStats'
        enabled: true
      }
      {
        category: 'AzureSiteRecoveryRecoveryPoints'
        enabled: true
      }
      {
        category: 'AzureSiteRecoveryReplicationDataUploadRate'
        enabled: true
      }
      {
        category: 'AzureSiteRecoveryProtectedDiskDataChurn'
        enabled: true
      }
      {
        category: 'CoreAzureBackup'
        enabled: true
      }
      {
        category: 'CoreAzureBackup'
        enabled: true
      }
      {
        category: 'AddonAzureBackupJobs'
        enabled: true
      }
      {
        category: 'AddonAzureBackupAlerts'
        enabled: true
      }
      {
        category: 'AddonAzureBackupPolicy'
        enabled: true
      }
      {
        category: 'AddonAzureBackupStorage'
        enabled: true
      }
      {
        category: 'AddonAzureBackupProtectedInstance'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Health'
        enabled: true
      }
    ]
  }
}

output principalId string = bvault.identity.principalId
output policy_operational_blob string = operationalPolicyBlob.id
output policy_vaulted_blob string = vaultedPolicyBlob.id
output policy_disk string = policyDisk.id
