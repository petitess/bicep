targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param plan object
param vmSize string
param computerName string
param availabilitySetName string
param imageReference object
param osDiskSizeGB int
param dataDisks array
param networkInterfaces array
param vnetname string
param vnetrg string
param backup object
param rsvRg string
param rsvName string
param rsvDefaultPolicy string
param log string
param ag string
param monitor object
param extensions bool
param deployLock bool
param DataWinId string
param DataLinuxId string
param dataEndpointId string
param certificateUrl string
param kvId string
param installCompCert bool
param loadBalancerBackendAddressPoolId string = ''
param kvRg string
param kvName string

var pass = 'A1.${uniqueString(subscription().id, resourceGroup().name, name)}2025'

resource vm 'Microsoft.Compute/virtualMachines@2024-07-01' = {
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
      adminUsername: 'azadmin'
      adminPassword: pass
      allowExtensionOperations: true
      secrets: installCompCert
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

resource disk 'Microsoft.Compute/disks@2024-03-02' = [
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
      tier: dataDisk.?tier ?? null
      creationData: {
        createOption: dataDisk.createOption
      }
    }
  }
]

resource nic 'Microsoft.Network/networkInterfaces@2024-05-01' = [
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
              id: resourceId(vnetrg, 'Microsoft.Network/virtualNetworks/subnets', vnetname, interface.subnet)
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

resource pip 'Microsoft.Network/publicIPAddresses@2024-05-01' = [
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

resource lockPip 'Microsoft.Authorization/locks@2020-05-01' = [
  for (interface, i) in networkInterfaces: if (interface.publicIPAddress) {
    name: 'dontdelete-pip-${i + 1}'
    scope: pip[i]
    properties: {
      level: 'CanNotDelete'
    }
  }
]

module vmBackup 'vmBackup.bicep' = if (backup.enabled) {
  scope: resourceGroup(rsvRg)
  name: '${vm.name}-Backup'
  params: {
    protectedItem: 'vm;iaasvmcontainerv2;${resourceGroup().name};${vm.name}'
    protectionContainer: 'iaasvmcontainer;iaasvmcontainerv2;${resourceGroup().name};${vm.name}'
    rsvName: rsvName
    rsvPolicy: rsvDefaultPolicy
    sourceId: vm.id
  }
}

module vmAlert 'vmAlert.bicep' = if (monitor.alert) {
  name: '${vm.name}-Alert'
  params: {
    ag: ag
    enabled: monitor.enabled
    location: location
    log: log
    name: vm.name == 'vmcaprod01' ? vm.properties.osProfile.computerName : vm.name
  }
}

resource DependencyAgentExtension 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = if (extensions) {
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

resource AMA 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = if (extensions || contains(
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

resource amaAssociationEndpoint 'Microsoft.Insights/dataCollectionRuleAssociations@2023-03-11' = if (extensions || imageReference.publisher == 'canonical') {
  name: 'configurationAccessEndpoint'
  scope: vm
  properties: {
    description: 'Association of data collection endpoint. Deleting this association will break the data collection for VMs.'
    dataCollectionEndpointId: dataEndpointId
  }
}

module sec 'vmsec.bicep' = {
  name: '${name}-sec'
  scope: resourceGroup(kvRg)
  params: {
    kvName: kvName
    name: name
    pass: pass
  }
}

resource lock 'Microsoft.Authorization/locks@2020-05-01' = if (deployLock) {
  name: 'dontdelete'
  properties: {
    level: 'CanNotDelete'
  }
}

output id string = vm.id
output name string = vm.name
output PrincipalId string = vm.identity.principalId
