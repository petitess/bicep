targetScope = 'resourceGroup'

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
param vnetname string
param vnetrg string

resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
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
        diskSizeGB: osDiskSizeGB
      }
      dataDisks: [for dataDisk in dataDisks: {
        lun: dataDisk.lun
        name: '${name}-${dataDisk.name}'
        createOption: 'Attach'
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

resource disk 'Microsoft.Compute/disks@2023-01-02' = [for dataDisk in dataDisks: if (dataDisk.createOption == 'Empty') {
  name: '${name}-${dataDisk.name}'
  location: location
  tags: resourceGroup().tags
  sku: {
    name: dataDisk.storageAccountType
  }
  properties: {
    diskSizeGB: dataDisk.diskSizeGB
    creationData: {
      createOption: dataDisk.createOption
    }
  }
}]

resource nic 'Microsoft.Network/networkInterfaces@2023-04-01' = [for (interface, i) in networkInterfaces: {
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
            id: resourceId(vnetrg, 'Microsoft.Network/virtualNetworks/subnets', vnetname, interface.subnet)
          }
        }
      }
    ]
    enableIPForwarding: interface.enableIPForwarding
    enableAcceleratedNetworking: interface.enableAcceleratedNetworking
  }
}]

resource pip 'Microsoft.Network/publicIPAddresses@2023-04-01' = [for (interface, i) in networkInterfaces: if (interface.publicIPAddress) {
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

resource run 'Microsoft.Compute/virtualMachines/runCommands@2023-03-01' = {
  name: 'run'
  parent: vm
  location: location
  tags: tags
  properties: {
    source: {
      script: ''' 
      New-Item -Path "C://" -Name runCommand.txt -ItemType File -Confirm:$false -Value "RunCommand" -Force

      $securePassword = ConvertTo-SecureString "12345.abc" -AsPlainText -Force
      New-LocalUser -Name "user02" -Password $securePassword -Confirm:$false

      if (Test-Path "c:\\temp\\Firefox.exe"){}else{Invoke-WebRequest -Uri "https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=sv-SE&_gl=1*g9bxup*_ga*NTgwNDg1NzE3LjE2NzcwNjgwNTQ.*_ga_MQ7767QQQW*MTY4Mjk0ODExMC4xLjAuMTY4Mjk0ODExMC4wLjAuMA.." -OutFile c:\\temp\\Firefox.exe}
      if (Test-Path "C:\\Program Files\\Mozilla Firefox\\firefox.exe"){}else{Start-Process -Wait -FilePath "c:\\temp\\Firefox.exe" -ArgumentList "/S" -PassThru}

      '''
    }
  }
}

output id string = vm.id
output name string = vm.name
