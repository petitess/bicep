param PublicIPname  string = 'PublicipSQL'

param publicIpSku string = 'Basic'

param publicIPAllocationMethod string = 'Dynamic'

param location string = resourceGroup().location

param vnetName string = 'JasonsVnets'

param subnetName string = 'B3CARE-SE-DB'

param nicName string = 'SQLnic'

param AdminUsername string = 'sek'
param AdminPassword string = '12345678.abc'

param networkSecurityGroupName string = 'SQLSecurityGroup'

param computerName string = 'SQLserv'

param VmName string = 'SQLServer'

var VnetPath = '${resourceGroup().id}/providers/Microsoft.Network/virtualNetworks/${vnetName}'

var subnetRef = '${VnetPath}/subnets/${subnetName}'

param OSdisk string = 'SQLdisk'

param DataDisk string = 'SQLdata'


resource pip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: PublicIPname
  location: resourceGroup().location
  sku: {
    name: publicIpSku
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
  }
}


resource securityGroup 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: networkSecurityGroupName
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
 

resource nic2 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetRef
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
  }
}


resource windowsVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: VmName
  location: resourceGroup().location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2_v3'
    }
    osProfile: {
      computerName: computerName
      adminUsername: AdminUsername
      adminPassword: AdminPassword
      windowsConfiguration: {
        provisionVMAgent: true
      }
      allowExtensionOperations: true
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: OSdisk
        caching: 'None'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      dataDisks: [        {
        name:  DataDisk
        diskSizeGB: 128
        lun: 0
        createOption: 'Empty'
      }
    ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic2.id
        }
      ]
    }
  }
}
