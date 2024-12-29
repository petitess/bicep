targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param plan object
param vmSize string
param imageReference object
param osDiskSizeGB int
param dataDisks array
param networkInterfaces array
param vnetname string
param vnetrg string
param log string
param ag string
param monitor object
param loadBalancerBackendAddressPoolId string
param IloadBalancerBackendAddressPoolId string
param availabilitySetName string
param deployLock bool
param kvRg string
param kvName string

var pass = 'A1.${uniqueString(subscription().id, resourceGroup().name, name)}2025'

resource vm 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: name
  location: location
  tags: tags
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
    availabilitySet: {
      id: resourceId('Microsoft.Compute/availabilitySets', availabilitySetName)
    }
    osProfile: {
      computerName: name
      adminUsername: 'azadmin'
      adminPassword: pass
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
        enabled: true
      }
    }
  }
}

resource disk 'Microsoft.Compute/disks@2024-03-02' = [
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
            loadBalancerBackendAddressPools: interface.externalLoadBalancer
              ? [
                  {
                    id: loadBalancerBackendAddressPoolId
                  }
                ]
              : interface.internalLoadBalancer
                  ? [
                      {
                        id: IloadBalancerBackendAddressPoolId
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
    }
  }
]

module vmAlert 'vmAlert.bicep' = if (monitor.alert) {
  name: '${vm.name}-Alert'
  params: {
    ag: ag
    enabled: monitor.enabled
    location: location
    log: log
    name: vm.name
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
