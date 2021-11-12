//Ändra prefix
param prefix string = 'AD01'

param publicIpSku string = 'Basic'

param publicIPAllocationMethod string = 'Dynamic'

param location string = resourceGroup().location

param AdminUsername string = 'B3Admin'

param vmSize string = 'Standard_D2s_v3'

param AdminPassword string = '12345678.abc'

param SubnetPath string 

param publisher string = 'MicrosoftWindowsServer'
param offer string = 'WindowsServer'
param skus string = '2019-Datacenter'

resource pip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: 'PublicIP_${prefix}'
  location: resourceGroup().location
  sku: {
    name: publicIpSku
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
  }
}

resource securityGroup 'Microsoft.Network/networkSecurityGroups@2021-03-01' = {
  name: 'NSG_${prefix}'
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-3389'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}
 
resource nic 'Microsoft.Network/networkInterfaces@2021-03-01' = {
  name: 'NIC_${prefix}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: SubnetPath
          }
          //Static ip test upload
          privateIPAddress: '10.112.0.10'
          privateIPAddressVersion: 'IPv4'
          privateIPAllocationMethod: 'Static'
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: securityGroup.id
    }
  }
}

resource windowsVM 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: 'Vm_${prefix}'
  location: resourceGroup().location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: '${prefix}server'
      adminUsername: AdminUsername
      adminPassword: AdminPassword
      windowsConfiguration: {
        provisionVMAgent: true
      }
      allowExtensionOperations: true
    }
    storageProfile: {
      imageReference: {
        publisher: publisher
        offer: offer
        sku: skus
        version: 'latest'
      }
      osDisk: {
        name: 'OSdisk_${prefix}'
        caching: 'None'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
      dataDisks: [        {
        name:  'Data_disk_${prefix}'
        diskSizeGB: 128
        lun: 0
        createOption: 'Empty'
      }
    ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}
