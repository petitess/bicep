targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param plan object
param vmSize string
param computerName string
param availabilitySetName string
@secure()
param adminUsername string = 'azadmin'
@secure()
param adminPassword string = '123456789.abc'
param imageReference object
param osDiskSizeGB int
param dataDisks array = []
param networkInterfaces array
param vnetName string
param vnetRg string
param extensions bool
param DataWinId string = ''
param DataLinuxId string = ''
param certificateUrl string = ''
param kvId string = ''
param installCert bool = false
param loadBalancerBackendAddressPoolId string = ''
param deployIIS bool

resource vm 'Microsoft.Compute/virtualMachines@2024-03-01' = {
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
      computerName: computerName
      adminUsername: adminUsername
      adminPassword: adminPassword
      allowExtensionOperations: true
      secrets: installCert
        ? [
            {
              sourceVault: {
                id: kvId
              }
              vaultCertificates: [
                {
                  certificateStore: 'My'
                  certificateUrl: certificateUrl
                }
              ]
            }
          ]
        : []
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
          caching: dataDisk.caching
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
        enabled: true
      }
    }
  }
}

resource disk 'Microsoft.Compute/disks@2023-10-02' = [
  for dataDisk in dataDisks: if (dataDisk.createOption == 'Empty') {
    name: '${name}-${dataDisk.name}'
    location: location
    tags: contains(dataDisk, 'diskLetter')
      ? union(tags, {
          DiskLetter: dataDisk.diskLetter
        })
      : tags
    sku: {
      name: dataDisk.storageAccountType
    }
    properties: {
      diskSizeGB: dataDisk.diskSizeGB
      tier: contains(dataDisk, 'tier') ? dataDisk.tier : null
      creationData: {
        createOption: dataDisk.createOption
      }
    }
  }
]

resource nic 'Microsoft.Network/networkInterfaces@2023-11-01' = [
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
              id: resourceId(vnetRg, 'Microsoft.Network/virtualNetworks/subnets', vnetName, interface.subnet)
            }
            loadBalancerBackendAddressPools: !empty(loadBalancerBackendAddressPoolId)
              ? [
                  {
                    id: loadBalancerBackendAddressPoolId
                  }
                ]
              : []
          }
        }
      ]
      enableIPForwarding: interface.enableIPForwarding
      enableAcceleratedNetworking: interface.enableAcceleratedNetworking
    }
  }
]

resource pip 'Microsoft.Network/publicIPAddresses@2023-11-01' = [
  for (interface, i) in networkInterfaces: if (interface.publicIPAddress) {
    name: 'pip-${name}-nic-${i + 1}'
    location: location
    tags: tags
    sku: {
      name: 'Standard'
    }
    properties: {
      publicIPAllocationMethod: 'Static'
      dnsSettings: {
        domainNameLabel: 'pip-${name}-nic-${i + 1}'
      }
    }
  }
]

resource DependencyAgentExtension 'Microsoft.Compute/virtualMachines/extensions@2024-03-01' = if (extensions) {
  parent: vm
  name: 'DependencyAgentWindows'
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: 'DependencyAgentWindows'
    typeHandlerVersion: '9.5'
    autoUpgradeMinorVersion: true
  }
}

//Aktiveras när Log Analytics Agent avvecklas 2024
resource AMA 'Microsoft.Compute/virtualMachines/extensions@2024-03-01' = if (extensions || contains(
  imageReference.publisher,
  'canonical'
)) {
  parent: vm
  name: contains(imageReference.publisher, 'windows') || contains(imageReference.publisher, 'microsoft')
    ? 'AzureMonitorWindowsAgent'
    : 'AzureMonitorLinuxAgent'
  location: location
  properties: {
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    publisher: 'Microsoft.Azure.Monitor'
    type: contains(imageReference.publisher, 'windows') || contains(imageReference.publisher, 'microsoft')
      ? 'AzureMonitorWindowsAgent'
      : 'AzureMonitorLinuxAgent'
    typeHandlerVersion: contains(imageReference.publisher, 'windows') || contains(imageReference.publisher, 'microsoft')
      ? '1.8'
      : '1.25'
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

resource associationWin 'Microsoft.Insights/dataCollectionRuleAssociations@2023-03-11' = if (extensions || imageReference.publisher == 'canonical') {
  name: 'data-${vm.name}'
  scope: vm
  properties: {
    description: 'Association of data collection rule. Deleting this association will break the data collection for this windows VMs.'
    dataCollectionRuleId: extensions ? DataWinId : DataLinuxId
  }
}

resource virtualMachine_IIS 'Microsoft.Compute/virtualMachines/extensions@2024-03-01' = if (deployIIS) {
  name: 'IIS'
  location: location
  parent: vm
  properties: {
    autoUpgradeMinorVersion: true
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.9'
    settings: {
      commandToExecute: 'powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path "C:\\inetpub\\wwwroot\\Default.htm" -Value "\\<h1>$($env:computername)</h1>"'
    }
  }
}

output id string = vm.id
output name string = vm.name
output PrincipalId string = vm.identity.principalId
