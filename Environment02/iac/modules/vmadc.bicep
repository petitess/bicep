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
param vnet string
// param backup object
// param rsvRg string
// param rsvName string
// param rsvDefaultPolicy string
// param rsvWeeklyPolicy string
param logRg string
param logLocation string
param log string
//param logApi string
param ag string
param monitor object
//param extensions bool

resource vm 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: name
  location: location
  tags: tags
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
          //id: '${resourceGroup().id}/providers/Microsoft.Compute/disks/${name}-${dataDisk.name}'
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

resource disk 'Microsoft.Compute/disks@2022-03-02' = [for dataDisk in dataDisks: if (dataDisk.createOption == 'Empty') {
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

resource nic 'Microsoft.Network/networkInterfaces@2022-01-01' = [for (interface, i) in networkInterfaces: {
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
            //id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet, interface.subnet) 
            id: '${vnet}/subnets/${interface.subnet}'
          }
        }
      }
    ]
    enableIPForwarding: interface.enableIPForwarding
    enableAcceleratedNetworking: interface.enableAcceleratedNetworking
  }
}]

resource pip 'Microsoft.Network/publicIPAddresses@2022-01-01' = [for (interface, i) in networkInterfaces: if (interface.publicIPAddress) {
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

// module vmBackup 'vmBackup.bicep' = if (backup.enabled) {
//   scope: resourceGroup(rsvRg)
//   name: '${vm.name}-Backup'
//   params: {
//     protectedItem: 'vm;iaasvmcontainerv2;${resourceGroup().name};${vm.name}'
//     protectionContainer: 'iaasvmcontainer;iaasvmcontainerv2;${resourceGroup().name};${vm.name}'
//     rsvName: rsvName
//     rsvPolicy: backup.weekly ? rsvWeeklyPolicy : rsvDefaultPolicy
//     sourceId: vm.id
//   }
// }

module vmAlert 'vmAlert.bicep' = if (monitor.alert) {
  scope: resourceGroup(logRg)
  name: '${vm.name}-Alert'
  params: {
    ag: ag
    enabled: monitor.enabled
    location: logLocation
    log: log
    name: vm.name
  }
}

// resource workspaceExtension 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = if (extensions) {
//   parent: vm
//   name: 'MicrosoftMonitoringAgent'
//   location: location
//   properties: {
//     autoUpgradeMinorVersion: true
//     publisher: 'Microsoft.EnterpriseCloud.Monitoring'
//     type: 'MicrosoftMonitoringAgent'
//     typeHandlerVersion: '1.0'
//     settings: {
//       workspaceId: reference(log, logApi).customerId
//     }
//     protectedSettings: {
//       workspaceKey: listKeys(log, logApi).primarySharedKey
//     }
//   }
// }

// resource workspaceExtension2 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = if (imageReference.publisher == 'canonical') {
//   parent: vm
//   name: 'MicrosoftMonitoringAgent2'
//   location: location
//   properties: {
//     autoUpgradeMinorVersion: true
//     publisher: 'Microsoft.EnterpriseCloud.Monitoring'
//     type: 'OmsAgentForLinux'
//     typeHandlerVersion: '1.14'
//     settings: {
//       workspaceId: reference(log, logApi).customerId
//     }
//     protectedSettings: {
//       workspaceKey: listKeys(log, logApi).primarySharedKey
//     }
//   }
// }

// resource DependencyAgentExtension 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = if (extensions) {
//   parent: vm
//   name: 'DependencyAgentWindows'
//   location: location
//   properties: {
//     publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
//     type: 'DependencyAgentWindows'
//     typeHandlerVersion: '9.5'
//     autoUpgradeMinorVersion: true
//   }
// }

output id string = vm.id
output name string = vm.name
