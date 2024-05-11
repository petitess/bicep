using '../main.bicep'

param env = 'dev'
param location = 'swedencentral'
param config = {
  product: 'sy'
  location: 'sc'
  tags: {
    Product: 'System'
    Environment: 'Development'
    CostCenter: '0000'
  }
}
param vnet = {
  addressPrefixes: [
    '10.100.55.0/24'
  ]
  subnets: [
    {
      name: 'snet-vm'
      addressPrefix: '10.100.55.0/27'
      rules: [
        {
          name: 'nsgsr-allow-http-frontdoor-inbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: 'AzureFrontDoor.Backend'
            sourcePortRange: '*'
            destinationAddressPrefixes: [
              '10.100.55.4/32'
              '10.100.55.5/32'
            ]
            destinationPortRanges: [
              80
            ]
            protocol: 'Tcp'
            priority: 100
            direction: 'Inbound'
          }
        }
        {
          name: 'nsgsr-allow-rdp-inbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: 'Internet'
            sourcePortRange: '*'
            destinationAddressPrefixes: [
              '10.100.55.4/32'
              '10.100.55.5/32'
            ]
            destinationPortRanges: [
              80
            ]
            protocol: 'Tcp'
            priority: 110
            direction: 'Inbound'
          }
        }
        {
          name: 'nsgsr-allow-internet-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: '10.100.55.0/24'
            sourcePortRange: '*'
            destinationAddressPrefix: 'Internet'
            destinationPortRange: '*'
            protocol: '*'
            priority: 100
            direction: 'Outbound'
          }
        }
        {
          name: 'nsgsr-allow-infra-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: '10.100.55.0/24'
            sourcePortRange: '*'
            destinationAddressPrefix: '10.100.10.0/24'
            destinationPortRange: '*'
            protocol: '*'
            priority: 200
            direction: 'Outbound'
          }
        }
        {
          name: 'nsgsr-allow-all-spokes-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: '10.100.55.0/24'
            sourcePortRange: '*'
            destinationAddressPrefix: '10.100.0.0/16'
            destinationPortRange: '*'
            protocol: '*'
            priority: 300
            direction: 'Outbound'
          }
        }
      ]
    }
    {
      name: 'snet-pep'
      addressPrefix: '10.100.55.32/27'
      rules: []
    }
  ]
}

param vms = [
  {
    name: 'vmiisdev01'
    rgName: 'rg-vmiisdev01'
    availabilitySetName: 'avail-vmiisdev01'
    tags: {
      Application: 'Management'
      Service: 'Management'
      UpdateManagement: 'Critical_Monthly_GroupA'
      Autoshutdown: 'No'
    }
    vmSize: 'Standard_B2ms'
    plan: {}
    imageReference: {
      publisher: 'microsoftwindowsserver'
      offer: 'windowsserver'
      sku: '2022-datacenter'
      version: 'latest'
    }
    osDiskSizeGB: 128
    dataDisks: []
    networkInterfaces: [
      {
        privateIPAllocationMethod: 'Static'
        privateIPAddress: '10.100.55.4'
        primary: true
        subnet: 'snet-vm'
        publicIPAddress: true
        enableIPForwarding: false
        enableAcceleratedNetworking: false
      }
    ]
    extensions: false
    deployIIS: true
  }
  {
    name: 'vmiisdev02'
    rgName: 'rg-vmiisdev01'
    availabilitySetName: 'avail-vmiisdev01'
    tags: {
      Application: 'Management'
      Service: 'Management'
      UpdateManagement: 'Critical_Monthly_GroupA'
      Autoshutdown: 'No'
    }
    vmSize: 'Standard_B2ms'
    plan: {}
    imageReference: {
      publisher: 'microsoftwindowsserver'
      offer: 'windowsserver'
      sku: '2022-datacenter'
      version: 'latest'
    }
    osDiskSizeGB: 128
    dataDisks: []
    networkInterfaces: [
      {
        privateIPAllocationMethod: 'Static'
        privateIPAddress: '10.100.55.5'
        primary: true
        subnet: 'snet-vm'
        publicIPAddress: true
        enableIPForwarding: false
        enableAcceleratedNetworking: false
      }
    ]
    extensions: false
    deployIIS: true
  }
]

param frontdoorEndpoints = [
  {
    appName: 'vmiisdev'
    DnsZoneName: ''
    deployCNAME: false
    isCompressionEnabled: false
    probeProtocol: 'Http'
    queryStringCachingBehavior: 'IgnoreQueryString'
    forwardingProtocol: 'HttpOnly'
    origins: [
      {
        appFqdn: 'pip-vmiisdev01-nic-1.swedencentral.cloudapp.azure.com'
      }
      {
        appFqdn: 'pip-vmiisdev02-nic-1.swedencentral.cloudapp.azure.com'
      }
    ]
    customRules: []
  }
]
