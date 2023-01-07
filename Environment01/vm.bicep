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
param vnetname string
param vnetrg string
param backup object
param rsvRg string
param rsvName string
param rsvDefaultPolicy string
param rsvWeeklyPolicy string
param logLocation string
param log string
param ag string
param monitor object
param WindowsOS bool
param LinuxOS bool
param DataWinId string
param DataLinuxId string
param maintenanceid string
param availabilitySetName string
param UpdateMgmtV2 bool

var script01 = 'powershell Install-WindowsFeature -Name RSAT-AD-Tools -IncludeAllSubFeature'
var script02 = 'powershell Install-WindowsFeature -Name RSAT-DHCP -IncludeAllSubFeature'
var script03 = 'powershell Install-WindowsFeature -Name RSAT-DNS-Server -IncludeAllSubFeature'
var script04 = 'powershell Install-WindowsFeature -Name RSAT-ADCS -IncludeAllSubFeature'

resource vm 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  plan: empty(plan) ? null : {
    name: plan.name
    product: plan.product
    publisher: plan.publisher
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: name
      adminUsername: adminUsername
      adminPassword: adminPassword
      allowExtensionOperations: true
      windowsConfiguration: UpdateMgmtV2 ? {
        patchSettings:  {
          patchMode: 'AutomaticByPlatform'
          assessmentMode: 'AutomaticByPlatform'
          automaticByPlatformSettings: {
            rebootSetting: 'IfRequired'
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
    availabilitySet: availabilitySetName == '' ? null : {
      id: resourceId('Microsoft.Compute/availabilitySets', availabilitySetName)
    }
  }
}

resource disk 'Microsoft.Compute/disks@2022-07-02' = [for dataDisk in dataDisks: if (dataDisk.createOption == 'Empty') {
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

resource nic 'Microsoft.Network/networkInterfaces@2022-07-01' = [for (interface, i) in networkInterfaces: {
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
            id: resourceId(vnetrg, 'Microsoft.Network/virtualNetworks/subnets', vnetname, interface.subnet)
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
}]

resource pip 'Microsoft.Network/publicIPAddresses@2022-07-01' = [for (interface, i) in networkInterfaces: if (interface.publicIPAddress) {
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
  scope: resourceGroup(rsvRg)
  name: '${vm.name}-Backup'
  params: {
    protectedItem: 'vm;iaasvmcontainerv2;${resourceGroup().name};${vm.name}'
    protectionContainer: 'iaasvmcontainer;iaasvmcontainerv2;${resourceGroup().name};${vm.name}'
    rsvName: rsvName
    rsvPolicy: backup.weekly ? rsvWeeklyPolicy : rsvDefaultPolicy
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
    vmid: vm.id
    name: vm.name
  }
}

resource DependencyAgentExtension 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = if(WindowsOS) {
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

resource AMAwin 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = if(WindowsOS || LinuxOS) {
  parent: vm
  name: WindowsOS ? 'AzureMonitorWindowsAgent' : 'AzureMonitorLinuxAgent'
  location: location
  properties: {
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    publisher:  'Microsoft.Azure.Monitor'
    type: WindowsOS ? 'AzureMonitorWindowsAgent' : 'AzureMonitorLinuxAgent'
    typeHandlerVersion: WindowsOS ? '1.11' : '1.24'
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

resource NWExtension 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = if (WindowsOS) {
  name: 'AzureNetworkWatcherExtension'
  location: location
  parent: vm
  tags: tags
  properties: {
    autoUpgradeMinorVersion: true
    publisher: 'Microsoft.Azure.NetworkWatcher'
    type: 'NetworkWatcherAgentWindows'
    typeHandlerVersion: '1.4'
    settings: {
      autoUpgradeMinorVersion: false
    }
    protectedSettings: {}
  }
}

resource associationWin 'Microsoft.Insights/dataCollectionRuleAssociations@2021-09-01-preview' = if(WindowsOS || LinuxOS) {
  name: 'data-${vm.name}'
  scope: vm
  properties: {
    description: 'Association of data collection rule. Deleting this association will break the data collection for this VM.'
    dataCollectionRuleId: WindowsOS ? DataWinId : DataLinuxId
  }
}

resource assignments 'Microsoft.Maintenance/configurationAssignments@2022-07-01-preview' = if(UpdateMgmtV2) {
  scope: vm
  name: '${name}-assignments'
  location: location
  properties: {
    maintenanceConfigurationId: maintenanceid
    resourceId: vm.id
  }
}

resource powershell 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = if(vm.name == 'vmmgmttest01') {
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
