targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param plan object
param vmSize string
//@secure()
param adminUsername string
//@secure()
param adminPass string
param imageReference object
param osDiskSizeGB int
param dataDisks array
param networkInterfaces array
param vnetname string
param vnetrg string
param AzureMonitorAgent bool
param DataWinId string
param DataLinuxId string

resource vm 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: name
  location: location
  tags: tags
  identity:  {
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
      adminPassword: adminPass
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
  }
}]

resource pip 'Microsoft.Network/publicIPAddresses@2022-07-01' = [for (interface, i) in networkInterfaces: if (interface.publicIPAddress) {
  name: '${name}-nic-${i + 1}-pip'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}]

resource amaWindows 'Microsoft.Compute/virtualMachines/extensions@2022-11-01' = if(contains(imageReference.publisher, 'windows') && AzureMonitorAgent) {
  parent: vm 
  name: 'AzureMonitorWindowsAgent'
  location: location
  properties: {
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorWindowsAgent'
    typeHandlerVersion: '1.8'
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

resource amaLinux 'Microsoft.Compute/virtualMachines/extensions@2022-11-01' = if(contains(imageReference.publisher, 'canonical') && AzureMonitorAgent) {
  parent: vm
  name: 'AzureMonitorLinuxAgent'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorLinuxAgent'
    typeHandlerVersion: '1.25'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
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

resource amaAssociation 'Microsoft.Insights/dataCollectionRuleAssociations@2021-09-01-preview' = if(AzureMonitorAgent) {
  name: name
  scope: vm
  properties: {
    description: 'Association of data collection rule. Deleting this association will break the data collection for VMs.'
    dataCollectionRuleId: contains(imageReference.publisher, 'windows') ? DataWinId  : DataLinuxId
  }
}

output id string = vm.id
output name string = vm.name
