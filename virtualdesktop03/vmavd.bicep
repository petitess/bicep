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
param imageReference object //string
param osDiskSizeGB int
param privateIPAddress string
param subnetname string
param vnetname string 
param vnetrg string
param RegistrationToken string
param domainFQDN string

var script01 = 'powershell if (Test-Path c:\\AVD){}else{New-Item -Path c:\\ -Name AVD -ItemType Directory -Force}'
var script02 = 'powershell Invoke-WebRequest -Uri https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv -OutFile c:\\AVD\\RDAgent.msi; powershell Invoke-WebRequest -Uri https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH -OutFile c:\\AVD\\Bootloader.msi'
var script03 = 'if (Test-Path c:\\AVD\\BootloaderInstalled){}else{Start-Process -Wait -FilePath "c:\\AVD\\Bootloader.msi" -ArgumentList "/quiet", "/norestart", "/passive" -PassThru;New-Item -Path c:\\AVD\\BootloaderInstalled}'
var script04 = 'if (Test-Path c:\\AVD\\RDagentInstalled){}else{Start-Process -FilePath "c:\\AVD\\RDAgent.msi" -ArgumentList /quiet, REGISTRATIONTOKEN=${RegistrationToken} -Wait -Passthru;New-Item -Path c:\\AVD\\RDagentInstalled}'


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
      imageReference: imageReference
      // imageReference: {
      //   id: '${rgvmimage.id}/providers/Microsoft.Compute/images/${param.avd.imagename}'
      // }
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
          // publicIPAddress: {
          //   id: pip.id
          // }
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
//For testing purposes
// resource pip 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
//   name: 'pip-${name}-nic'
//   location: location
//   tags: tags
//   sku: {
//     name: 'Standard'
//   }
//   properties: {
//     publicIPAllocationMethod: 'Static'
//   }
// }

resource joindomain 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' =  {
  name: 'joindomain'
  location: location
  tags: tags
  parent: vm
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      Name: domainFQDN
      User: '${domainFQDN}\\${adminUsername}'
      Restart: 'true'
      Options: 3
    }
    protectedSettings: {
      Password: adminPassword
    }
  }
}

resource powershell 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  name: 'InstallAVDagents'
  location: location
  parent: vm
  dependsOn: [
    joindomain
  ]
  properties: {
    autoUpgradeMinorVersion: true
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    settings: {
      commandToExecute: '${script01};${script02};${script03};${script04}'
    }
  }
}

output id string = vm.id
output name string = vm.name
