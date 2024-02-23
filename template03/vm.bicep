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
param vnetRg string

resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
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
        //writeAcceleratorEnabled: true
        diskSizeGB: osDiskSizeGB
      }
      dataDisks: [for dataDisk in dataDisks: {
        lun: dataDisk.lun
        name: '${name}-${dataDisk.name}'
        caching: dataDisk.caching
        createOption: 'Attach'
        //writeAcceleratorEnabled: true
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

resource disk 'Microsoft.Compute/disks@2023-10-02' = [for dataDisk in dataDisks: if (dataDisk.createOption == 'Empty') {
  name: '${name}-${dataDisk.name}'
  location: location
  tags: resourceGroup().tags
  sku: {
    name: dataDisk.storageAccountType
  }
  properties: {
    diskSizeGB: dataDisk.diskSizeGB
    tier: contains(dataDisk, 'tier') ? dataDisk.tier :null
    creationData: {
      createOption: dataDisk.createOption
    }
  }
}]

resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' = [for (interface, i) in networkInterfaces: {
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
            id: resourceId(vnetRg, 'Microsoft.Network/virtualNetworks/subnets', vnetName, interface.subnet)
          }
        }
      }
    ]
    enableIPForwarding: interface.enableIPForwarding
    enableAcceleratedNetworking: interface.enableAcceleratedNetworking
  }
}]

resource pip 'Microsoft.Network/publicIPAddresses@2023-09-01' = [for (interface, i) in networkInterfaces: if (interface.publicIPAddress) {
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

output id string = vm.id
output name string = vm.name
