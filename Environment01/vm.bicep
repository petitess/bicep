targetScope = 'resourceGroup'

@maxLength(15)
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
param vnetName string
param backup object
param infraRg string
param rsvName string
param rsvDefaultPolicy string
param logLocation string
param log string
param ag string
param monitor object
param WindowsOS bool
param LinuxOS bool
param DataWinId string
param DataLinuxId string
param maintenanceId string
param availabilitySetName string
param UpdateMgmtV2 bool

var script01 = 'powershell Install-WindowsFeature -Name RSAT-AD-Tools -IncludeAllSubFeature'
var script02 = 'powershell Install-WindowsFeature -Name RSAT-DHCP -IncludeAllSubFeature'
var script03 = 'powershell Install-WindowsFeature -Name RSAT-DNS-Server -IncludeAllSubFeature'
var script04 = 'powershell Install-WindowsFeature -Name RSAT-ADCS -IncludeAllSubFeature'

resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: name
  location: location
  tags: tags
  plan: empty(plan) ? null : {
    name: plan.name
    product: plan.product
    publisher: plan.publisher
  }
  properties: {
    availabilitySet: !empty(availabilitySetName) ? {
      id: resourceId('Microsoft.Compute/availabilitySets', availabilitySetName)
    } : null
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: name
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: contains(imageReference.publisher, 'microsoftwindowsserver') ? {
        patchSettings: {
          patchMode: 'AutomaticByPlatform'
          automaticByPlatformSettings: {
            bypassPlatformSafetyChecksOnUserSchedule: true
          }
        }
      } : null
    }
    storageProfile: {
      imageReference: imageReference
      osDisk: {
        createOption: 'FromImage'
        diskSizeGB: osDiskSizeGB
      }
      dataDisks: [for dataDisk in dataDisks: {
        lun: dataDisk.lun
        name: '${name}-${dataDisk.name}'
        createOption: 'Attach'
        diskSizeGB: dataDisk.diskSizeGB
        managedDisk: {
          storageAccountType: dataDisk.storageAccountType
          id: resourceId('Microsoft.Compute/disks', '${name}-${dataDisk.name}')
        }
      }]
    }
    networkProfile: {
      networkInterfaces: [for (interface, i) in networkInterfaces: {
        id: nic[i].id
        properties: {
          primary: interface.primary
        }
      }]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource disk 'Microsoft.Compute/disks@2023-01-02' = [for dataDisk in dataDisks: if (dataDisk.createOption == 'Empty') {
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
}]

resource nic 'Microsoft.Network/networkInterfaces@2023-04-01' = [for (interface, i) in networkInterfaces: {
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
          publicIPAddress: interface.publicIPAddress ? {
            id: pip[i].id
          } : null
          subnet: {
            id: resourceId(infraRg, 'Microsoft.Network/virtualNetworks/subnets', vnetName, interface.subnet)
          }
        }
      }
    ]
    enableIPForwarding: interface.enableIPForwarding
    enableAcceleratedNetworking: interface.enableAcceleratedNetworking
  }
}]

resource pip 'Microsoft.Network/publicIPAddresses@2023-04-01' = [for (interface, i) in networkInterfaces: if (interface.publicIPAddress) {
  name: 'pip-${name}-nic-${i + 1}'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}]

module vmBackup 'vmBackup.bicep' = if (backup.enabled) {
  scope: resourceGroup(infraRg)
  name: '${vm.name}-Backup'
  params: {
    protectedItem: 'vm;iaasvmcontainerv2;${resourceGroup().name};${vm.name}'
    protectionContainer: 'iaasvmcontainer;iaasvmcontainerv2;${resourceGroup().name};${vm.name}'
    rsvName: rsvName
    rsvPolicy: rsvDefaultPolicy
    sourceId: vm.id
  }
}

module vmAlert 'vmalert.bicep' = if (monitor.alert) {
  name: '${vm.name}-Alert'
  params: {
    ag: ag
    enabled: monitor.enabled
    location: logLocation
    log: log
    vmId: vm.id
    name: vm.name
  }
}

resource DependencyAgentExtension 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = if (WindowsOS) {
  parent: vm
  name: 'DependencyAgentWindows'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: 'DependencyAgentWindows'
    typeHandlerVersion: '9.5'
    autoUpgradeMinorVersion: true
  }
}

resource AMAwin 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = if (WindowsOS || LinuxOS) {
  parent: vm
  name: WindowsOS ? 'AzureMonitorWindowsAgent' : 'AzureMonitorLinuxAgent'
  location: location
  properties: {
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    publisher: 'Microsoft.Azure.Monitor'
    type: WindowsOS ? 'AzureMonitorWindowsAgent' : 'AzureMonitorLinuxAgent'
    typeHandlerVersion: WindowsOS ? '1.18' : '1.27'
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

resource associationWin 'Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01' = if (WindowsOS || LinuxOS) {
  name: 'data-${vm.name}'
  scope: vm
  properties: {
    dataCollectionRuleId: WindowsOS ? DataWinId : DataLinuxId
  }
}

resource assignments 'Microsoft.Maintenance/configurationAssignments@2023-04-01' = if (UpdateMgmtV2) {
  scope: vm
  name: '${name}-assignments'
  location: location
  properties: {
    maintenanceConfigurationId: maintenanceId
    resourceId: vm.id
  }
}

resource powershell 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = if (vm.name == 'vmmgmttest01') {
  name: 'InstallRSAT'
  location: location
  parent: vm
  properties: {
    autoUpgradeMinorVersion: true
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    settings: {
      commandToExecute: '${script01};${script02};${script03};${script04}'
    }
  }
}

output id string = vm.id
output name string = vm.name
