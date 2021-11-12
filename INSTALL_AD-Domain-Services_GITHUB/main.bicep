//https://medium.com/codex/deploy-a-virtual-machine-with-skype-ndi-runtime-and-obs-ndi-installed-using-bicep-c216437f88f2

@description('Location of resources')
param location string = resourceGroup().location
@description('Local name for the VM can be whatever you want')
param prefix string = '3'
param vm_name string = 'SEKsrv${prefix}'
@description('User name for the Virtual Machine.')
param adminUsername string = 'sek'
@description('Password for the Virtual Machine.')
//@secure()
param adminPassword string = '12345678.abc'
@description('Desired Size of the VM. Any valid option accepted but if you choose premium storage type you must choose a DS class VM size.')
param vmSize string = 'Standard_D2s_v3'
param virtualNetwork_name string = 'stream-vnet${prefix}'
param nic_name string = 'stream-nic${prefix}'
param publicIPAddress_name string = 'stream-ip${prefix}'
param dnsprefix string = 'streamvm${prefix}'
param networkSecurityGroup_name string = 'stream-nsg${prefix}'
@description('PowerShell script name to execute')
param scriptFileName string = 'AD-Domain-Services.ps1'
@description('List of Chocolatey packages to install separated by a semi-colon eg. linqpad;sysinternals')
//param chocoPackages string = 'obs-studio;skype'


var vmImagePublisher = 'microsoftwindowsserver'
var vmImageOffer = 'windowsserver'
var sku = '2019-datacenter'
@description('Public uri location of PowerShell Chocolately setup script')
var scriptLocation = 'https://raw.githubusercontent.com/petitess/bicep/main/AD-Domain-Services.ps1'


resource networkSecurityGroup_name_resource 'Microsoft.Network/networkSecurityGroups@2019-07-01' = {
  name: networkSecurityGroup_name
  location: location
  properties: {
    securityRules: [
      {
        name: 'RDP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 300
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource virtualNetwork_name_default 'Microsoft.Network/virtualNetworks/subnets@2019-07-01' = {
  parent: virtualNetwork_name_resource
  name: 'default'
  properties: {
    addressPrefix: '10.0.4.0/24'
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource virtualNetwork_name_resource 'Microsoft.Network/virtualNetworks@2019-07-01' = {
  name: virtualNetwork_name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.4.0/24'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.4.0/24'
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
}

resource pip 'Microsoft.Network/publicIPAddresses@2019-07-01' = {
  name: publicIPAddress_name
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    idleTimeoutInMinutes: 4
    /*dnsSettings: {
      domainNameLabel: dnsprefix
    }*/
  }
}

resource nic_name_resource 'Microsoft.Network/networkInterfaces@2019-07-01' = {
  name: nic_name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: '10.0.4.4'
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.id
          }
          subnet: {
            id: virtualNetwork_name_default.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    networkSecurityGroup: {
      id: networkSecurityGroup_name_resource.id
    }
  }
}

resource vm_name_resource 'Microsoft.Compute/virtualMachines@2019-07-01' = {
  name: vm_name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: vmImagePublisher
        offer: vmImageOffer
        sku: sku
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        name: '${vm_name}_OsDisk'
        createOption: 'FromImage'
        caching: 'ReadWrite'
      }
    }
    osProfile: {
      computerName: vm_name
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic_name_resource.id
        }
      ]
    }
  }
}

resource vm_name_GPUDrivers 'Microsoft.Compute/virtualMachines/extensions@2019-07-01' = {
  parent: vm_name_resource
  name: 'GPUDrivers'
  location: location
  tags: {
    displayName: 'gpu-nvidia-drivers'
  }
  properties: {
    publisher: 'Microsoft.HpcCompute'
    type: 'NvidiaGpuDriverWindows'
    typeHandlerVersion: '1.2'
    autoUpgradeMinorVersion: true
  }
  dependsOn: [
    vm_name_SetupChocolatey
  ]
}

resource vm_name_SetupChocolatey 'Microsoft.Compute/virtualMachines/extensions@2019-07-01' = {
  parent: vm_name_resource
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
