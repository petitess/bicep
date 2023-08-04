targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param plan object
param vmSize string
param computerName string
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
param replicationPolicyId string
param rsvAsrName string
param rsvAsrRg string
param vmAsrRg string
param primaryStId string
param rsvAsrVnetId string
param asrSubId string
param siteRecovery bool

resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
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
      computerName: computerName
      adminUsername: adminUsername
      adminPassword: adminPassword
      allowExtensionOperations: true
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
        caching: dataDisk.caching
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
    dnsSettings: {
      dnsServers: []
    }
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

module vmSiteRecovery 'vmSiteRecovery.bicep' = if (siteRecovery) {
  scope: resourceGroup(asrSubId, rsvAsrRg)
  name: '${vm.name}-SiteRecovery'
  params: {
    replicationPolicyId: replicationPolicyId
    rsvAsrName: rsvAsrName
    vmId: vm.id
    vmName: vm.name
    osDiskId: vm.properties.storageProfile.osDisk.managedDisk.id
    primaryStId: primaryStId
    recoverySnetName: networkInterfaces[0].subnet
    recoveryVnetId: rsvAsrVnetId
    recoveryRgId: subscriptionResourceId(asrSubId, 'Microsoft.Resources/resourceGroups', vmAsrRg)
    dataDisks: [for (dataDisk, i) in dataDisks: {
      diskId: disk[i].id
      primaryStagingAzureStorageAccountId: primaryStId
      recoveryResourceGroupId: subscriptionResourceId(asrSubId, 'Microsoft.Resources/resourceGroups', vmAsrRg)
      recoveryReplicaDiskAccountType: 'Premium_LRS'
      recoveryTargetDiskAccountType: 'Premium_LRS'
    }]
  }
}

output id string = vm.id
output name string = vm.name
output PrincipalId string = vm.identity.principalId
