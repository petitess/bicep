targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param vmSize string
@secure()
param adminUsername string
@secure()
param adminPassword string
param snetId string
param DataWinId string
param availabilitySetName string
param registrationInfoToken string
param hostPoolName string

resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    availabilitySet: {
      id: resourceId('Microsoft.Compute/availabilitySets', availabilitySetName)
    }
    osProfile: {
      computerName: name
      adminUsername: adminUsername
      adminPassword: adminPassword
      allowExtensionOperations: true
      windowsConfiguration: {
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'microsoftwindowsdesktop'
        offer: 'office-365'
        sku: 'win11-23h2-avd-m365'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        diskSizeGB: 128
        name: '${name}-osdisk'
      }
    }
    networkProfile: {
      networkInterfaces: [{
        id: nic.id
        properties: {
          primary: true
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

resource nic 'Microsoft.Network/networkInterfaces@2023-06-01' = {
  name: '${name}-nic'
  location: location
  tags: resourceGroup().tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig${1}'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: snetId
          }
        }
      }
    ]
    enableIPForwarding: false
    enableAcceleratedNetworking: false
  }
}

resource AMA 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = if (true) {
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

resource amaAssociation 'Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01' = {
  name: name
  scope: vm
  properties: {
    description: 'Association of data collection rule. Deleting this association will break the data collection for VMs.'
    dataCollectionRuleId: DataWinId
  }
}

resource joinEntraIdIntune 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = if(true) {
  parent: vm
  name: 'AADLoginForWindows'
  location: location
  tags: tags
  properties: {
    autoUpgradeMinorVersion: true
    publisher: 'Microsoft.Azure.ActiveDirectory'
    type: 'AADLoginForWindows'
    typeHandlerVersion: '2.0'
    settings: {
      mdmId: '0000000a-0000-0000-c000-000000000000'
     }
  }
}

resource joinVdpool 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = if(true) {
  parent: vm
  name: 'Microsoft.PowerShell.DSC'
  location: location
  tags: tags
  properties: {
    autoUpgradeMinorVersion: true
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.73'
    settings: {
      modulesUrl: 'https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_1.0.02507.246.zip'
      configurationFunction: 'Configuration.ps1\\AddSessionHost'
      properties: {
        hostPoolName: hostPoolName
        registrationInfoToken: registrationInfoToken
        aadJoin: true
        UseAgentDownloadEndpoint: true
        aadJoinPreview: false
        mdmId: '0000000a-0000-0000-c000-000000000000'
      }
    }
  }
}

resource run 'Microsoft.Compute/virtualMachines/runCommands@2023-09-01' = if(true) {
  name: 'run-fxlogix-config'
  parent: vm
  location: location
  tags: tags
  properties: {
    source: {
      script: loadTextContent('../scripts/runCommand.ps1')
    }
  }
}
