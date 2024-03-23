targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param plan object = {}
param vmSize string
@secure()
param adminUsername string
@secure()
param adminPassword string
param imageReference object
param osDiskSizeGB int
param dataDisks array = []
param networkInterfaces array
param snetId string
param AzureMonitorAgent bool = false
param DataWinId string = ''
param DataLinuxId string = ''
param availabilitySetName string = ''

var git = 'sudo apt-get install git -y'
var azurecli = 'curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash'
var pwsh = 'apt-get install -y wget apt-transport-https software-properties-common; wget -q "https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb"; dpkg -i packages-microsoft-prod.deb; rm packages-microsoft-prod.deb; apt-get update; apt-get install -y powershell'
var unzip = 'sudo apt-get install unzip'
var zip = 'sudo apt-get install zip'

var docker1 = 'sudo apt-get update'
var docker2 = 'sudo apt-get install ca-certificates curl'
var docker3 = 'sudo install -m 0755 -d /etc/apt/keyrings'
var docker4 = 'sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc'
var docker5 = 'sudo chmod a+r /etc/apt/keyrings/docker.asc'
var docker6 = 'sudo echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null'
var docker7 = 'sudo apt-get update'
var docker8 = 'sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y'
var docker9 = 'sudo newgrp docker; sudo usermod -aG docker azadmin; sudo systemctl restart docker'

var docker = '${docker1};${docker2};${docker3};${docker4};${docker5};${docker6};${docker7};${docker8};${docker9}'

var unixScripts = '${git};${azurecli};${pwsh};${unzip};${zip};${docker}'

var folder = 'powershell if (Test-Path c:\\Tools){}else{New-Item -Path c:\\ -Name Tools -ItemType Directory -Force}'
var getSdk = 'powershell Invoke-WebRequest -Uri https://download.visualstudio.microsoft.com/download/pr/e3f91c3f-dbcc-44cb-a319-9cb15c9b61b9/6c87d96b2294afed74ccf414e7747b5a/dotnet-sdk-7.0.400-win-x64.exe -OutFile c:\\Tools\\sdk7.exe'
var sdk = 'powershell Start-Process -FilePath "c:\\Tools\\sdk7.exe" -ArgumentList "-quiet" -Wait'
var GetAzureCliWin = 'powershell Invoke-WebRequest -Uri https://aka.ms/installazurecliwindowsx64 -OutFile c:\\Tools\\azurecli.msi'
var azureCliWin = 'powershell Start-Process -FilePath "c:\\Tools\\azurecli.msi" -ArgumentList "/quiet" -Wait'
var getPwshWin = 'powershell Invoke-WebRequest -Uri https://github.com/PowerShell/PowerShell/releases/download/v7.4.1/PowerShell-7.4.1-win-x64.msi -OutFile c:\\Tools\\pwsh.msi'
var pwshWin = 'powershell Start-Process -FilePath "c:\\Tools\\pwsh.msi" -ArgumentList "/quiet" -Wait'

resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  plan: empty(plan)
    ? null
    : {
        name: plan.name
        product: plan.product
        publisher: plan.publisher
      }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    availabilitySet: availabilitySetName != ''
      ? {
          id: resourceId('Microsoft.Compute/availabilitySets', availabilitySetName)
        }
      : null
    osProfile: {
      computerName: name
      adminUsername: adminUsername
      adminPassword: adminPassword
      allowExtensionOperations: true
      windowsConfiguration: contains(imageReference.publisher, 'windowsserver')
        ? {
            patchSettings: {
              patchMode: 'AutomaticByPlatform'
              automaticByPlatformSettings: {
                bypassPlatformSafetyChecksOnUserSchedule: true
              }
            }
          }
        : null
    }
    storageProfile: {
      imageReference: imageReference
      osDisk: {
        createOption: 'FromImage'
        diskSizeGB: osDiskSizeGB
      }
      dataDisks: [
        for dataDisk in dataDisks: {
          lun: dataDisk.lun
          name: '${name}-${dataDisk.name}'
          createOption: 'Attach'
          managedDisk: {
            storageAccountType: dataDisk.storageAccountType
            id: resourceId('Microsoft.Compute/disks', '${name}-${dataDisk.name}')
          }
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        for (interface, i) in networkInterfaces: {
          id: nic[i].id
          properties: {
            primary: interface.primary
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
}

resource disk 'Microsoft.Compute/disks@2023-10-02' = [
  for dataDisk in dataDisks: if (dataDisk.createOption == 'Empty') {
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
  }
]

resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' = [
  for (interface, i) in networkInterfaces: {
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
            publicIPAddress: interface.publicIPAddress
              ? {
                  id: pip[i].id
                }
              : null
            subnet: {
              id: snetId
            }
          }
        }
      ]
      enableIPForwarding: interface.enableIPForwarding
      enableAcceleratedNetworking: interface.enableAcceleratedNetworking
      dnsSettings: {
        dnsServers: []
      }
    }
  }
]

resource pip 'Microsoft.Network/publicIPAddresses@2023-09-01' = [
  for (interface, i) in networkInterfaces: if (interface.publicIPAddress) {
    name: 'pip-${name}-nic-${i + 1}'
    location: location
    tags: tags
    sku: {
      name: 'Standard'
    }
    properties: {
      publicIPAllocationMethod: 'Static'
    }
  }
]

resource AMA 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' =
  if (AzureMonitorAgent) {
    parent: vm
    name: contains(imageReference.publisher, 'windows') ? 'AzureMonitorWindowsAgent' : 'AzureMonitorLinuxAgent'
    location: location
    properties: {
      autoUpgradeMinorVersion: true
      enableAutomaticUpgrade: true
      publisher: 'Microsoft.Azure.Monitor'
      type: contains(imageReference.publisher, 'windows') ? 'AzureMonitorWindowsAgent' : 'AzureMonitorLinuxAgent'
      typeHandlerVersion: contains(imageReference.publisher, 'windows') ? '1.8' : '1.25'
      settings: {
        authentication: {
          managedIdentity: {
            'identifier-name': 'mi_res_id'
            'identifier-value': vm.id
          }
        }
      }
    }
  }

resource amaAssociation 'Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01' =
  if (AzureMonitorAgent) {
    name: name
    scope: vm
    properties: {
      description: 'Association of data collection rule. Deleting this association will break the data collection for VMs.'
      dataCollectionRuleId: contains(imageReference.publisher, 'windows') ? DataWinId : DataLinuxId
    }
  }

resource toolsLinux 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' =
  if (imageReference.publisher == 'canonical' && contains(name, 'vmdevops')) {
    name: 'CustomScriptDevOps'
    location: location
    parent: vm
    properties: {
      publisher: 'Microsoft.Azure.Extensions'
      type: 'CustomScript'
      typeHandlerVersion: '2.1'
      autoUpgradeMinorVersion: true
      protectedSettings: {
        commandToExecute: unixScripts
      }
    }
  }

resource toolsWindows 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' =
  if (imageReference.publisher == 'microsoftwindowsserver' && contains(name, 'vmdevops')) {
    name: 'InstallAgents'
    location: location
    parent: vm
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
