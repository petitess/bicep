param name string
param location string
param tags object = resourceGroup().tags
param vmSize string
param plan object = {}
@secure()
param adminUsername string
@secure()
param adminPass string
param computerNamePrefix string
param imageReference object
param osDiskSizeGB int
param dataDisks array
param networkInterfaces array
param vnetName string
param vnetRg string

var git = 'sudo apt-get install git -y'
var azurecli = 'curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash'
var pwsh = 'apt-get install -y wget apt-transport-https software-properties-common; wget -q "https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb"; dpkg -i packages-microsoft-prod.deb; rm packages-microsoft-prod.deb; apt-get update; apt-get install -y powershell'
var unzip = 'sudo apt-get install unzip'
var zip = 'sudo apt-get install zip'

var folder = 'powershell if (Test-Path c:\\Tools){}else{New-Item -Path c:\\ -Name Tools -ItemType Directory -Force}'
var getSdk = 'powershell Invoke-WebRequest -Uri https://download.visualstudio.microsoft.com/download/pr/e3f91c3f-dbcc-44cb-a319-9cb15c9b61b9/6c87d96b2294afed74ccf414e7747b5a/dotnet-sdk-7.0.400-win-x64.exe -OutFile c:\\Tools\\sdk7.exe'
var sdk = 'powershell Start-Process -FilePath "c:\\Tools\\sdk7.exe" -ArgumentList "-quiet" -Wait'
var GetAzureCliWin = 'powershell Invoke-WebRequest -Uri https://aka.ms/installazurecliwindowsx64 -OutFile c:\\Tools\\azurecli.msi'
var azureCliWin = 'powershell Start-Process -FilePath "c:\\Tools\\azurecli.msi" -ArgumentList "/quiet" -Wait'
var getPwshWin = 'powershell Invoke-WebRequest -Uri https://github.com/PowerShell/PowerShell/releases/download/v7.3.6/PowerShell-7.3.6-win-x64.msi -OutFile c:\\Tools\\pwsh.msi'
var pwshWin = 'powershell Start-Process -FilePath "c:\\Tools\\pwsh.msi" -ArgumentList "/quiet" -Wait'

resource ss 'Microsoft.Compute/virtualMachineScaleSets@2023-03-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: vmSize
    tier: 'Standard'
  }
  plan: empty(plan) ? null : {
    name: plan.name
    product: plan.product
    publisher: plan.publisher
  }
  properties: {
    singlePlacementGroup: false
    overprovision: false
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
                    id: resourceId(vnetRg, 'Microsoft.Network/virtualNetworks/subnets', vnetName, interface.subnet)
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

resource tools 'Microsoft.Compute/virtualMachineScaleSets/extensions@2023-03-01' = if (imageReference.publisher == 'canonical') {
  name: 'CustomScriptDevOps'
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

resource powershell 'Microsoft.Compute/virtualMachineScaleSets/extensions@2023-03-01' = if (imageReference.publisher == 'microsoftwindowsserver') {
  name: 'InstallAgents'
  parent: ss
  properties: {
    autoUpgradeMinorVersion: true
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    settings: {
      commandToExecute: '${folder};${getSdk};${sdk};${GetAzureCliWin};${azureCliWin};${getPwshWin};${pwshWin}'
    }
  }
}
