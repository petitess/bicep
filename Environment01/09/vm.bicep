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

output vmid string = vm.id
