targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param plan object
param vmSize string
//@secure()
param adminUsername string
//@secure()
param adminPassword string
param imageReference string
param osDiskSizeGB int
param privateIPAddress string
param subnetname string
param vnetname string 
param vnetrg string

resource vm 'Microsoft.Compute/virtualMachines@2022-08-01' = {
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
      // windowsConfiguration: {
      //   patchSettings: {
      //     patchMode: 'AutomaticByPlatform'
      //     assessmentMode: 'AutomaticByPlatform'
      //   }
      // }
    }
    storageProfile: {
      imageReference: {
        id: imageReference
      }
      osDisk: {
        createOption: 'FromImage'
        diskSizeGB: osDiskSizeGB
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
          properties:{
            primary: true
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

resource nic 'Microsoft.Network/networkInterfaces@2022-05-01' = {
  name: '${name}-nic-${1}'
  location: location
  tags: resourceGroup().tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig${1}'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: privateIPAddress
          subnet: {
            id: resourceId(vnetrg, 'Microsoft.Network/virtualNetworks/subnets', vnetname, subnetname)
          }
        }
      }
    ]
    enableIPForwarding: false
    enableAcceleratedNetworking: false
  }
}

output id string = vm.id
output name string = vm.name
