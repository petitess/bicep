targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param plan object
param vmSize string
@secure()
param adminUsername string
@secure()
param adminPassword string
param imageReference object
param osDiskSizeGB int
param dataDisks array
param networkInterfaces array
param snetId string
param AzureMonitorAgentWin bool
param AzureMonitorAgentLinux bool
param DataWinId string
param DataLinuxId string
param availabilitySetName string
param dataEndpointId string
param dataChangeTracking string

resource vm 'Microsoft.Compute/virtualMachines@2025-04-01' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  plan: empty(plan)
    ? null
    : {
        name: plan.name
        product: plan.product
        publisher: plan.publisher
      }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    availabilitySet: availabilitySetName != ''
      ? {
          id: resourceId('Microsoft.Compute/availabilitySets', availabilitySetName)
        }
      : null
    osProfile: {
      computerName: name
      adminUsername: adminUsername
      adminPassword: adminPassword
      allowExtensionOperations: true
      windowsConfiguration: contains(imageReference.publisher, 'windowsserver')
        ? {
            patchSettings: {
              patchMode: 'AutomaticByPlatform'
              automaticByPlatformSettings: {
                bypassPlatformSafetyChecksOnUserSchedule: true
              }
            }
          }
        : null
    }
    storageProfile: {
      imageReference: imageReference
      osDisk: {
        createOption: 'FromImage'
        diskSizeGB: osDiskSizeGB
      }
      dataDisks: [
        for dataDisk in dataDisks: {
          lun: dataDisk.lun
          name: '${name}-${dataDisk.name}'
          createOption: 'Attach'
          managedDisk: {
            storageAccountType: dataDisk.storageAccountType
            id: resourceId('Microsoft.Compute/disks', '${name}-${dataDisk.name}')
          }
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        for (interface, i) in networkInterfaces: {
          id: nic[i].id
          properties: {
            primary: interface.primary
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource disk 'Microsoft.Compute/disks@2025-01-02' = [
  for dataDisk in dataDisks: if (dataDisk.createOption == 'Empty') {
    name: '${name}-${dataDisk.name}'
    location: location
    tags: resourceGroup().tags
    sku: {
      name: dataDisk.storageAccountType
    }
    properties: {
      diskSizeGB: dataDisk.diskSizeGB
      creationData: {
        createOption: dataDisk.createOption
      }
    }
  }
]

resource nic 'Microsoft.Network/networkInterfaces@2024-10-01' = [
  for (interface, i) in networkInterfaces: {
    name: '${name}-nic-${i + 1}'
    location: location
    tags: resourceGroup().tags
    properties: {
      ipConfigurations: [
        {
          name: 'ipconfig${i + 1}'
          properties: {
            privateIPAllocationMethod: interface.privateIPAllocationMethod
            privateIPAddress: interface.privateIPAllocationMethod == 'Static' ? interface.privateIPAddress : null
            publicIPAddress: interface.publicIPAddress
              ? {
                  id: pip[i].id
                }
              : null
            subnet: {
              id: snetId
            }
          }
        }
      ]
      enableIPForwarding: interface.enableIPForwarding
      enableAcceleratedNetworking: interface.enableAcceleratedNetworking
      dnsSettings: {
        dnsServers: []
      }
    }
  }
]

resource pip 'Microsoft.Network/publicIPAddresses@2024-10-01' = [
  for (interface, i) in networkInterfaces: if (interface.publicIPAddress) {
    name: 'pip-${name}-nic-${i + 1}'
    location: location
    tags: tags
    sku: {
      name: 'Standard'
    }
    properties: {
      publicIPAllocationMethod: 'Static'
    }
  }
]

resource AMA 'Microsoft.Compute/virtualMachines/extensions@2025-04-01' = if (AzureMonitorAgentWin || AzureMonitorAgentLinux) {
  parent: vm
  name: AzureMonitorAgentWin ? 'AzureMonitorWindowsAgent' : 'AzureMonitorLinuxAgent'
  location: location
  properties: {
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    publisher: 'Microsoft.Azure.Monitor'
    type: AzureMonitorAgentWin ? 'AzureMonitorWindowsAgent' : 'AzureMonitorLinuxAgent'
    typeHandlerVersion: AzureMonitorAgentWin ? '1.0' : '1.25'
    settings: {
      authentication: {
        managedIdentity: {
          'identifier-name': 'mi_res_id'
          'identifier-value': vm.id
        }
      }
    }
  }
}

resource amaAssociationEndpoint 'Microsoft.Insights/dataCollectionRuleAssociations@2023-03-11' = if (AzureMonitorAgentWin || AzureMonitorAgentLinux) {
  name: 'configurationAccessEndpoint'
  scope: vm
  properties: {
    description: 'Association of data collection endpoint. Deleting this association will break the data collection for VMs.'
    dataCollectionEndpointId: dataEndpointId
  }
}

resource amaAssociation 'Microsoft.Insights/dataCollectionRuleAssociations@2023-03-11' = if (AzureMonitorAgentWin || AzureMonitorAgentLinux) {
  name: name
  scope: vm
  properties: {
    description: 'Association of data collection rule. Deleting this association will break the data collection for VMs.'
    dataCollectionRuleId: AzureMonitorAgentWin ? DataWinId : DataLinuxId
  }
}

resource amaVmInsightsAssociation 'Microsoft.Insights/dataCollectionRuleAssociations@2023-03-11' = if (AzureMonitorAgentWin || AzureMonitorAgentLinux) {
  name: '${name}-changetracking'
  scope: vm
  properties: {
    description: 'Association of data collection rule. Deleting this association will break the data collection for VMs.'
    dataCollectionRuleId: dataChangeTracking
  }
}

resource ChangeTrackingExtension 'Microsoft.Compute/virtualMachines/extensions@2025-04-01' = if (AzureMonitorAgentWin) {
  parent: vm
  name: 'ChangeTracking-Windows'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.ChangeTrackingAndInventory'
    type: 'ChangeTracking-Windows'
    typeHandlerVersion: '2.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
  }
}

// resource encryptionExtensionWindows 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = if (AzureMonitorAgentWin) {
//   parent: vm
//   name: 'AzureDiskEncryption'
//   location: location
//   properties: {
//     autoUpgradeMinorVersion: true
//     publisher: 'Microsoft.Azure.Security'
//     type: 'AzureDiskEncryption'
//     typeHandlerVersion: '2.2'
//     settings: {
//       EncryptionOperation: 'EnableEncryption'
//       KeyEncryptionAlgorithm: 'RSA-OAEP'
//       VolumeType: 'All'
//       KeyVaultURL: kvUrl
//       KeyVaultResourceId: kvId
//       KeyEncryptionKeyURL: keyUrl
//       KekVaultResourceId: kvId
//     }
//   }
// }

// resource IaaSAntimalwareExtension 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = if (AzureMonitorAgentWin) {
//   parent: vm
//   name: 'IaaSAntimalware'
//   location: location
//   properties: {
//     publisher: 'Microsoft.Azure.Security'
//     type: 'IaaSAntimalware'
//     typeHandlerVersion: '1.3'
//     autoUpgradeMinorVersion: true
//     settings: {
//       AntimalwareEnabled: true
//       RealtimeProtectionEnabled: true
//       ScheduledScanSettings: {
//         isEnabled: true
//         day: 1
//         time: 1320
//         scanType: 'Quick'
//       }
//       Exclusions: {
//         Extensions: ''
//         Paths: ''
//         Processes: ''
//       }
//     }
//   }
// }

// resource vmaccess 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = if (AzureMonitorAgentWin) {
//   parent: vm
//   name: 'enablevmaccess'
//   location: location
//   properties: {
//     publisher: 'Microsoft.Compute'
//     type: 'VMAccessAgent'
//     typeHandlerVersion: '2.0'
//     autoUpgradeMinorVersion: true
//     settings: {}
//   }
// }
