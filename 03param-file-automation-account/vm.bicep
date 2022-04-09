targetScope = 'resourceGroup'

param publicIpSku string = 'Basic'
param publicIPAllocationMethod string = 'Dynamic'
param location string = resourceGroup().location
@secure()
param adminUsername string
param vmSize string
@secure()
param adminPassword string
param publisher string  
param offer string  
param skus string  
param networkInterfaces array
@maxLength(15)
param name string
param tags object
param vnetId string


resource pip 'Microsoft.Network/publicIPAddresses@2021-05-01' = [for (interface, i) in networkInterfaces: if (interface.publicIPAddress) {
  name: 'pip-${name}-nic-${i + 1}'
  location: location
  sku: {
    name: publicIpSku
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
  }
}]

resource nic 'Microsoft.Network/networkInterfaces@2021-05-01' =  [for (interface, i) in networkInterfaces: {
  name: '${name}-nic-${i + 1}'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: interface.privateIPAllocationMethod
          privateIPAddress: interface.privateIPAllocationMethod == 'Static' ? interface.privateIPAddress : null
          publicIPAddress: interface.publicIPAddress ? {
            id: pip[i].id
          } : null
          subnet: {
            id: '${vnetId}/subnets/${interface.subnet}'
          }
        }
      }
    ]
  }
}]

resource windowsVM 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: name
      adminUsername: adminUsername
      adminPassword: adminPassword
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
        name: 'OSdisk_${name}'
        caching: 'None'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
      dataDisks: [       
        {
        name:  'Data_disk_${name}'
        diskSizeGB: 128
        lun: 0
        createOption: 'Empty'
      }
    ]
    }
    networkProfile: {
      networkInterfaces: [for (interface, i) in networkInterfaces: {
        id: nic[i].id
        properties: {
          primary: interface.primary
        }
      }]
    }
  }
}

//output vmAD string = windowsVM.name
