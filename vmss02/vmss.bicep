targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param plan object
param vmSize string
//@secure()
param adminUsername string
//@secure()
param adminPass string
param computerNamePrefix string
param imageReference object
param osDiskSizeGB int
param dataDisks array
param networkInterfaces array
param vnetname string
param vnetrg string

var git = 'sudo apt-get install git -y'
var azurecli = 'curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash'
var pwsh = 'apt-get install -y wget apt-transport-https software-properties-common; wget -q "https://packages.microsoft.com/config/ubuntu/23.04/packages-microsoft-prod.deb"; dpkg -i packages-microsoft-prod.deb; rm packages-microsoft-prod.deb; apt-get update; apt-get install -y powershell'
var unzip = 'sudo apt-get install unzip'
var zip = 'sudo apt-get install zip'

resource ss 'Microsoft.Compute/virtualMachineScaleSets@2023-03-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: vmSize
    tier: 'Standard'
    capacity: 0
  }
  identity: {
    type: 'SystemAssigned'
  }
  plan: empty(plan) ? null : {
    name: plan.name
    product: plan.product
    publisher: plan.publisher
  }
  properties: {
    singlePlacementGroup: false
    orchestrationMode: 'Uniform'
    upgradePolicy: {
      mode: 'Manual'
    }
    virtualMachineProfile: {
      osProfile: {
        adminUsername: adminUsername
        adminPassword: adminPass
        computerNamePrefix: computerNamePrefix
      }
      storageProfile: {
        osDisk: {
          createOption: 'FromImage'
          caching: 'ReadWrite'
          diskSizeGB: osDiskSizeGB
          managedDisk: {
            storageAccountType: 'Premium_LRS'
          }
        }
        imageReference: imageReference
        dataDisks: [for dataDisk in dataDisks: {
          lun: dataDisk.lun
          createOption: 'Empty'
          diskSizeGB: dataDisk.diskSizeGB
          caching: 'ReadWrite'
          managedDisk: {
            storageAccountType: dataDisk.storageAccountType
          }
        }]
      }
      networkProfile: {
        networkInterfaceConfigurations: [for (interface, i) in networkInterfaces: {
          name: '${name}-nic-${i + 1}'
          properties: {
            primary: interface.primary
            enableAcceleratedNetworking: interface.enableAcceleratedNetworking
            enableIPForwarding: interface.enableIPForwarding
            ipConfigurations: [
              {
                name: 'ipconfig${i + 1}'
                properties: {
                  subnet: {
                    id: resourceId(vnetrg, 'Microsoft.Network/virtualNetworks/subnets', vnetname, interface.subnet)
                  }
                }
              }
            ]
          }
        }]
      }
    }
  }
}

resource tools 'Microsoft.Compute/virtualMachineScaleSets/extensions@2023-03-01' = {
  name: 'CustomScript'
  parent: ss
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    protectedSettings: {
      commandToExecute: '${git};${azurecli};${pwsh};${unzip};${zip}'
    }
  }
}
