targetScope = 'resourceGroup'

@maxLength(15)
param name string
param location string
param tags object
param vmSize string
@secure()
param adminPassword string
@secure()
param adminUsername string
param osdiskSizeGB int
param imageReference object
param networkinterfaces array
param vnetid string
param datadisks array
param osdiskname string
param osWindows bool
param workspaceId string
param workspaceApi string
// param backupEnabled bool
// param policyId string
// param rsvName string
// param rsvRgName string

resource vm  'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    networkProfile: {
      networkInterfaces: [for (networkinterface, i) in networkinterfaces: {
          id: nic[i].id
      }]
    }
    osProfile: {
      adminPassword: adminPassword
      adminUsername: adminUsername
      computerName: name
      }
    storageProfile: {
      osDisk: {
        createOption:  'FromImage'
        diskSizeGB: osdiskSizeGB
        name: osdiskname
      }
      imageReference: imageReference  
      dataDisks: [for datadisk in datadisks:{
          createOption: 'Empty'
          lun: datadisk.lun
          diskSizeGB: datadisk.diskSizeGB
        }]
      
    }
    }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-08-01' = [for (networkinterface, i) in networkinterfaces: {
  name: '${name}-nic${i +1}'
  location: location
  tags: resourceGroup().tags
  properties: {
    ipConfigurations: [
      {
         name: 'ipconfig${i + 1}'
         properties:{
           primary: networkinterface.primary
           privateIPAllocationMethod: networkinterface.privateIPAllocationMethod
           privateIPAddress: networkinterface.privateIPAddress
           subnet: {
              id: '${vnetid}/subnets/${networkinterface.subnet}'
           }
           publicIPAddress: networkinterface.publicIPAddress ? {
             id: pip[i].id
           } : null
         }
        
      }
    ]
  }
}]


resource datadisk 'Microsoft.Compute/disks@2021-12-01' =  [for datadisk in datadisks: {
  name: '${name}-${datadisk.name}'
  location: location
  tags: tags
  sku: {
    name: datadisk.sku
  }
  properties: {

    creationData: {
      createOption: datadisk.createOption
    }
    diskSizeGB: datadisk.diskSizeGB
  }
}]

resource pip 'Microsoft.Network/publicIPAddresses@2021-08-01' = [for (networkinterface, i) in networkinterfaces: if (networkinterface.publicIPAddress) {
  name: '${name}-pip${i +1}'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}]

//Extension for log analytics
resource workspaceExtension 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = if (osWindows) {
  name: 'MonitoringAgent'
  location: location
  parent: vm
  tags: tags
  properties: {
    autoUpgradeMinorVersion: true
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'MicrosoftMonitoringAgent'
    typeHandlerVersion: '1.0'
    settings: { 
      workspaceId: reference(workspaceId, workspaceApi).customerId
    }
    protectedSettings: {
      workspaceKey: listKeys(workspaceId, workspaceApi).primarySharedKey
    }
  }
}

resource NWExtension 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = if (osWindows) {
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

// module vmbackup 'backup.bicep' = if(backupEnabled) {
//   name: 'module-${vm.name}-backup01'
//   scope: resourceGroup(rsvRgName)
//   params: {
//     location: location
//     policyId: policyId
//     sourceResourceId: vm.id
//     protectedItem: 'vm;iaasvmcontainerv2;${resourceGroup().name};${vm.name}'
//     protectionContainer: 'iaasvmcontainer;iaasvmcontainerv2;${resourceGroup().name};${vm.name}'
//     rsvName: rsvName
//   }
// }

output vmid string = vm.id
output nicconfig array = [for (nictype, i) in networkinterfaces: {
  subnet: nic[i].properties.ipConfigurations
}]
