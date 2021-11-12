param VMUserName string = 'sek'

//@secure()
param VMPassword string = '12345678.abc'
param CCVMPrefix string
param virtualMachineCount int
param VMSize string
param OS string
param availabilitySetName string
param location string = resourceGroup().location
param vNetName string
param vNetResourceGroup string
param SubnetName string
param availabilitySetPlatformFaultDomainCount int
param availabilitySetPlatformUpdateDomainCount int
param domainFQDN string = 'B3Care'
param domainJoinUserName string = 'sek'
param ouPath string
//param DNSad string 
//'B3Care.se\\sek'

//@secure()
param domainJoinUserPassword string = '12345678.abc'

var operatingSystemValues = {
  Server2012R2: {
    PublisherValue: 'MicrosoftWindowsServer'
    OfferValue: 'WindowsServer'
    SkuValue: '2012-R2-Datacenter'
  }
  Server2016: {
    PublisherValue: 'MicrosoftWindowsServer'
    OfferValue: 'WindowsServer'
    SkuValue: '2016-Datacenter'
  }
  Server2019: {
    PublisherValue: 'MicrosoftWindowsServer'
    OfferValue: 'WindowsServer'
    SkuValue: '2019-Datacenter'
  }
}
param subnetRef string
//= resourceId(vNetResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', vNetName, SubnetName)

resource availabilityset 'Microsoft.Compute/availabilitySets@2021-03-01' = {
  name: availabilitySetName
  location: location
  properties: {
    platformFaultDomainCount: availabilitySetPlatformFaultDomainCount
    platformUpdateDomainCount: availabilitySetPlatformUpdateDomainCount
  }
  sku: {
    name: 'Aligned'
  }
}

resource virtualmachine 'Microsoft.Compute/virtualMachines@2021-03-01' = [for i in range(0, virtualMachineCount): {
  name: '${CCVMPrefix}-${i + 1}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: VMSize
    }
    storageProfile: {
      imageReference: {
        publisher: operatingSystemValues[OS].PublisherValue
        offer: operatingSystemValues[OS].OfferValue
        sku: operatingSystemValues[OS].SkuValue
        version: 'latest'
      }
      osDisk: {
        name: 'OSDisk-${CCVMPrefix}-${i + 1}'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        caching: 'ReadWrite'
      }
    }
    osProfile: {
      computerName: '${CCVMPrefix}-${i + 1}'
      adminUsername: VMUserName
      windowsConfiguration: {
        provisionVMAgent: true
      }
      adminPassword: VMPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', '${CCVMPrefix}-${i + 1}-NIC1')
        }
      ]
    }
    availabilitySet: {
      id: availabilityset.id
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false        
      }
    }
  }
  dependsOn: [    
    nic
  ]
}]

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = [for i in range(0, virtualMachineCount): {
  name: '${CCVMPrefix}-${i + 1}-NIC1'
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
          subnet: {
            id: subnetRef
          }
        }
      }
    ]
    enableIPForwarding: false
  }
  dependsOn: [
    availabilityset
  ]
}]

resource joindomain 'Microsoft.Compute/virtualMachines/extensions@2021-03-01' = [for i in range(0, virtualMachineCount): {
  name: toLower('${CCVMPrefix}-${i + 1}/joindomain')
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      Name: domainFQDN
      User: '${domainFQDN}\\${domainJoinUserName}'
      Restart: 'true'
      Options: 3
      OUPath: 'OU=CCCcomputers,DC=B3Care,DC=se'
      //ouPath
    }
    protectedSettings: {
      Password: domainJoinUserPassword
    }
  }
  dependsOn: [
    virtualmachine
  ]
}]
