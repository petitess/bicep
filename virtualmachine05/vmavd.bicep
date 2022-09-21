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
param vnet string 

var script01 = 'powershell New-Item -Path c:\\ -Name AVD -ItemType Directory'
var script02 = 'powershell Invoke-WebRequest -Uri https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv -OutFile c:\\AVD\\RDAgent01.msi'
var script03 = 'powershell Invoke-WebRequest -Uri https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH -OutFile c:\\AVD\\Bootloader01.msi'

resource vm 'Microsoft.Compute/virtualMachines@2022-03-01' = {
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

resource nic 'Microsoft.Network/networkInterfaces@2022-01-01' = {
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
            id: '${vnet}/subnets/${subnetname}'
          }
        }
      }
    ]
    enableIPForwarding: false
    enableAcceleratedNetworking: false
  }
}

resource powershell 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  name: 'powershell'
  location: location
  parent: vm
  properties: {
    autoUpgradeMinorVersion: true
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.9'
    settings: {
      commandToExecute: '${script01};${script02};${script03}'
    }
  }
}


output id string = vm.id
output name string = vm.name
