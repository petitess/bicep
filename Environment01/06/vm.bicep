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
param diskSizeGB int
param imageReference object
param networkinterfaces array
param vnetid string

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
        diskSizeGB: diskSizeGB
      }
      imageReference: imageReference  
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
           privateIPAddress: networkinterface.privateIPAddress
           subnet: {
              id: '${vnetid}/subnets/${networkinterface.subnet}'
           }
         }
        
      }
    ]
  }
}]



