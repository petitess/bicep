using './main.bicep'

param environment = 'prod'
param vnet = {
  addressPrefixes: [
    '10.100.7.0/24'
    '10.100.11.0/24'
  ]
  subnets: [
    {
      name: 'snet-agw'
      addressPrefix: '10.100.7.0/24'
      serviceEndpoints: [
        {
          service: 'Microsoft.KeyVault'
        }
      ]
      routes: [
        {
          name: 'udr-private-a'
          properties: {
            addressPrefix: '10.0.0.0/8'
            nextHopType: 'VirtualAppliance'
            nextHopIpAddress: '10.100.9.4'
          }
        }
        {
          name: 'udr-private-b'
          properties: {
            addressPrefix: '172.16.0.0/12'
            nextHopType: 'VirtualAppliance'
            nextHopIpAddress: '10.100.9.4'
          }
        }
        {
          name: 'udr-private-c'
          properties: {
            addressPrefix: '192.168.0.0/16'
            nextHopType: 'VirtualAppliance'
            nextHopIpAddress: '10.100.9.4'
          }
        }
      ]
      rules: [
        {
          name: 'nsgsr-allow-gatewaymanager-inbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: 'GatewayManager'
            sourcePortRange: '*'
            destinationAddressPrefix: '*'
            destinationPortRange: '65200-65535'
            protocol: 'Tcp'
            priority: 100
            direction: 'Inbound'
          }
        }
        {
          name: 'nsgsr-allow-azureloadbalancer-inbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: 'AzureLoadBalancer'
            sourcePortRange: '*'
            destinationAddressPrefix: '*'
            destinationPortRange: '65200-65535'
            protocol: 'Tcp'
            priority: 200
            direction: 'Inbound'
          }
        }
        {
          name: 'nsgsr-allow-internet-inbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: 'Internet'
            sourcePortRange: '*'
            destinationAddressPrefix: '10.100.7.0/24'
            destinationPortRanges: [
              80
              443
            ]
            protocol: 'Tcp'
            priority: 300
            direction: 'Inbound'
          }
        }
      ]
      defaultRules: 'Inbound'
    }
    {
      name: 'snet-apim'
      addressPrefix: '10.100.11.0/27'
      delegation: 'Microsoft.ApiManagement/service'
    }
    {
      name: 'snet-pep'
      addressPrefix: '10.100.11.32/27'
    }
    {
      name: 'snet-mgmt'
      addressPrefix: '10.100.11.64/27'
      rules: [
        {
          name: 'nsgsr-allow-bastion-inbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: '10.100.9.64/26'
            sourcePortRange: '*'
            destinationAddressPrefix: '10.100.11.64/27'
            destinationPortRanges: [
              22
              3389
            ]
            protocol: 'Tcp'
            priority: 100
            direction: 'Inbound'
          }
        }
        {
          name: 'nsgsr-allow-all-spokes-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: '10.100.11.64/27'
            sourcePortRange: '*'
            destinationAddressPrefixes: [
              '10.100.0.0/16'
              '10.200.0.0/16'
            ]
            destinationPortRange: '*'
            protocol: '*'
            priority: 100
            direction: 'Outbound'
          }
        }
        {
          name: 'nsgsr-allow-internet-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: '10.100.11.64/27'
            sourcePortRange: '*'
            destinationAddressPrefix: 'Internet'
            destinationPortRange: '*'
            protocol: '*'
            priority: 200
            direction: 'Outbound'
          }
        }
      ]
    }
    {
      name: 'snet-inbound'
      addressPrefix: '10.100.11.96/27'
    }
    {
      name: 'snet-outbound'
      addressPrefix: '10.100.11.128/27'
      delegation: 'Microsoft.Web/serverFarms'
    }
  ]
}
param config = {
  product: 'infra'
  location: 'sc'
  tags: {
    Product: 'Common Infrastructure'
    Environment: 'Production'
    CostCenter: '0000'
  }
  vm: [
    {
      name: 'vmmgmtprod01'
      rgName: 'rg-vmmgmtprod01'
      availabilitySetName: ''
      tags: {
        Application: 'Management'
        Service: 'Management'
        UpdateManagement: 'Not_supported'
        Autoshutdown: 'No'
      }
      vmSize: 'Standard_B2ms'
      plan: {}
      imageReference: {
        publisher: 'microsoftwindowsdesktop'
        offer: 'windows-11'
        sku: 'win11-22h2-avd'
        version: 'latest'
      }
      osDiskSizeGB: 128
      dataDisks: []
      networkInterfaces: [
        {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.100.11.71'
          primary: true
          subnet: 'snet-mgmt'
          publicIPAddress: false
          enableIPForwarding: false
          enableAcceleratedNetworking: false
        }
      ]
      backup: {
        enabled: true
        rsvPolicyName: 'policy-vm7days01'
      }
      AzureMonitorAgent: true
    }
    {
      name: 'vmsqlprod01'
      rgName: 'rg-vmsqlprod01'
      availabilitySetName: ''
      tags: {
        Application: 'Management'
        Service: 'Management'
        UpdateManagement: 'Not_supported'
        Autoshutdown: 'No'
      }
      vmSize: 'Standard_B2ms'
      plan: {}
      imageReference: {
        publisher: 'microsoftwindowsdesktop'
        offer: 'windows-11'
        sku: 'win11-22h2-avd'
        version: 'latest'
      }
      osDiskSizeGB: 128
      dataDisks: []
      networkInterfaces: [
        {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.100.11.72'
          primary: true
          subnet: 'snet-mgmt'
          publicIPAddress: false
          enableIPForwarding: false
          enableAcceleratedNetworking: false
        }
      ]
      backup: {
        enabled: true
        rsvPolicyName: 'policy-vm7days01'
      }
      AzureMonitorAgent: true
    }
    {
      name: 'vmadproxyprod01'
      rgName: 'rg-vmadproxyprod01'
      availabilitySetName: 'avail-vmadproxyprod01'
      tags: {
        Application: 'Application Proxy'
        Service: 'Application Proxy'
        UpdateManagement: 'GroupA'
        Autoshutdown: 'No'
      }
      vmSize: 'Standard_B2s'
      plan: {}
      imageReference: {
        publisher: 'microsoftwindowsserver'
        offer: 'windowsserver'
        sku: '2022-datacenter-smalldisk'
        version: 'latest'
      }
      osDiskSizeGB: 70
      dataDisks: []
      networkInterfaces: [
        {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.100.11.75'
          primary: true
          subnet: 'snet-mgmt'
          publicIPAddress: false
          enableIPForwarding: false
          enableAcceleratedNetworking: false
        }
      ]
      backup: {
        enabled: true
        rsvPolicyName: 'policy-vm7days01'
      }
      AzureMonitorAgent: true
    }
    {
      name: 'vmadproxyprod02'
      rgName: 'rg-vmadproxyprod01'
      availabilitySetName: 'avail-vmadproxyprod01'
      tags: {
        Application: 'Application Proxy'
        Service: 'Application Proxy'
        UpdateManagement: 'GroupB'
        Autoshutdown: 'No'
      }
      vmSize: 'Standard_B2s'
      plan: {}
      imageReference: {
        publisher: 'microsoftwindowsserver'
        offer: 'windowsserver'
        sku: '2022-datacenter-smalldisk'
        version: 'latest'
      }
      osDiskSizeGB: 70
      dataDisks: []
      networkInterfaces: [
        {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.100.11.76'
          primary: true
          subnet: 'snet-mgmt'
          publicIPAddress: false
          enableIPForwarding: false
          enableAcceleratedNetworking: false
        }
      ]
      backup: {
        enabled: true
        rsvPolicyName: 'policy-vm7days01'
      }
      AzureMonitorAgent: true
    }
    {
      name: 'vmabcprod01'
      rgName: 'rg-vmabcprod01'
      availabilitySetName: 'avail-vmabcprod01'
      tags: {
        Application: 'Application Proxy'
        Service: 'Application Proxy'
        UpdateManagement: 'GroupA'
        Autoshutdown: 'No'
      }
      vmSize: 'Standard_B2s'
      plan: {}
      imageReference: {
        publisher: 'microsoftwindowsserver'
        offer: 'windowsserver'
        sku: '2022-datacenter-smalldisk'
        version: 'latest'
      }
      osDiskSizeGB: 70
      dataDisks: []
      networkInterfaces: [
        {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.100.11.77'
          primary: true
          subnet: 'snet-mgmt'
          publicIPAddress: false
          enableIPForwarding: false
          enableAcceleratedNetworking: false
        }
      ]
      backup: {
        enabled: true
        rsvPolicyName: 'policy-vm7days01'
      }
      AzureMonitorAgent: true
    }
    {
      name: 'vmabcprod02'
      rgName: 'rg-vmabcprod01'
      availabilitySetName: 'avail-vmabcprod01'
      tags: {
        Application: 'Application Proxy'
        Service: 'Application Proxy'
        UpdateManagement: 'GroupB'
        Autoshutdown: 'No'
      }
      vmSize: 'Standard_B2s'
      plan: {}
      imageReference: {
        publisher: 'microsoftwindowsserver'
        offer: 'windowsserver'
        sku: '2022-datacenter-smalldisk'
        version: 'latest'
      }
      osDiskSizeGB: 70
      dataDisks: []
      networkInterfaces: [
        {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.100.11.78'
          primary: true
          subnet: 'snet-mgmt'
          publicIPAddress: false
          enableIPForwarding: false
          enableAcceleratedNetworking: false
        }
      ]
      backup: {
        enabled: true
        rsvPolicyName: 'policy-vm7days01'
      }
      AzureMonitorAgent: true
    }
  ]
}
