param location string = resourceGroup().location
param subNetID string = 'sek'

resource virtualMachines_MIM_DC_01_name_resource 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: 'MIM-DC01'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2_v3'
    }
    storageProfile: {
      imageReference: {
        publisher: 'microsoftsqlserver'
        offer: 'sql2019-ws2019'
        sku: 'standard'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        name: 'OsDisk'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        diskSizeGB: 127
      }
      dataDisks: []
    }
    osProfile: {
      computerName: 'MIM-DC01'
      adminUsername: 'karol'
      adminPassword: '12345678.abc'
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
          assessmentMode: 'ImageDefault'
          enableHotpatching: false
        }
      }
      secrets: []
      allowExtensionOperations: true
      //requireGuestProvisionSignal: true
    }
    networkProfile: {
      networkApiVersion: '2020-11-01'
      networkInterfaceConfigurations: [
        {
          name: 'MIM-DC-01592'
          properties: {
            deleteOption: 'Delete'
            ipConfigurations: [
              {
                name: 'MIM-DC01-pi'
                properties: {
                  primary: true
                  privateIPAddressVersion: 'IPv4'
                  subnet: {
                    id: subNetID
                  }
                }
              }
            ]
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
