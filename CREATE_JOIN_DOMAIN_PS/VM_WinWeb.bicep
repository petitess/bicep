param existingVnetName string
param existingSubnetName string
param prefix string

param vmSize string = 'Standard_D2s_v3'

param vmAdminUsername string = 'sek'

//@secure()
param vmAdminPassword string = '12345678.abc'

param location string = resourceGroup().location
var imagePublisher = 'MicrosoftWindowsServer'
var imageOffer = 'WindowsServer'
var windowsOSVersion = '2019-Datacenter'
var nicName = '${prefix}-nic'
//var publicIpName = '${dnsLabelPrefix}-pip'
param subnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', existingVnetName, existingSubnetName)

param scriptFileName string = 'JoinDomain.ps1'
var scriptLocation = 'https://raw.githubusercontent.com/petitess/powershell/main/JoinDomain.ps1'


resource publicIp 'Microsoft.Network/publicIPAddresses@2021-03-01' = {
  name: 'PublicIP_${prefix}'
  location: resourceGroup().location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}


resource nic 'Microsoft.Network/networkInterfaces@2021-03-01' = {
  name: nicName
  location: location
  properties: {
    dnsSettings: {
      dnsServers: [
        '10.112.0.10'
      ]
    }
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIp.id
          }
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: prefix
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: prefix
      adminUsername: vmAdminUsername
      adminPassword: vmAdminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: windowsOSVersion
        version: 'latest'
      }
      osDisk: {
        name: '${prefix}-OsDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
      dataDisks: [
        {
          name: '${prefix}-DataDisk'
          caching: 'None'
          createOption: 'Empty'
          diskSizeGB: 1024
          lun: 0
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

resource vm_name_SetupChocolatey 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = {
  parent:  virtualMachine
  name: 'SetupChocolatey'
  location: location
  tags: {
    displayName: 'config-choco'
  }
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        scriptLocation
      ]
      commandToExecute: 'powershell.exe -ExecutionPolicy bypass -File ${scriptFileName}'
    }
  }
}
