using '../main.bicep'

param environment = 'stg'
param config = {
  product: 'infra'
  location: 'we'
  tags: {
    Product: 'Common Infrastructure'
    Environment: 'Staging'
    CostCenter: '9100'
  }
  vnet: {
    addressPrefixes: [
      '10.100.8.0/24'
      '10.100.12.0/24'
    ]
    subnets: [
      {
        name: 'snet-agw'
        addressPrefix: '10.100.8.0/24'
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
              destinationAddressPrefix: '10.100.8.0/24'
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
        addressPrefix: '10.100.12.0/27'
        delegation: 'Microsoft.ApiManagement/service'
      }
      {
        name: 'snet-pep'
        addressPrefix: '10.100.12.32/27'
      }
      {
        name: 'snet-mgmt'
        addressPrefix: '10.100.12.64/27'
        rules: [
          {
            name: 'nsgsr-allow-bastion-inbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.9.64/26'
              sourcePortRange: '*'
              destinationAddressPrefix: '10.100.12.64/27'
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
              sourceAddressPrefix: '10.100.12.64/27'
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
              sourceAddressPrefix: '10.100.12.64/27'
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
        addressPrefix: '10.100.12.96/27'
      }
      {
        name: 'snet-outbound'
        addressPrefix: '10.100.12.128/27'
        delegation: 'Microsoft.Web/serverFarms'
      }
    ]
  }
  agw: {
    privateIPAddress: '10.100.8.10'
    sslCertificates: [
    ]
    sites: []
    pathRules: []
  }
  kvPermissions: {
    appPermissions: {
      secrets: [
        'get'
      ]
    }
    userPermissions: {
      certificates: [
        'Get'
        'List'
        'Update'
        'Create'
        'Import'
        'Delete'
        'Recover'
        'Backup'
        'Restore'
        'ManageContacts'
        'ManageIssuers'
        'GetIssuers'
        'ListIssuers'
        'SetIssuers'
        'DeleteIssuers'
      ]
      keys: [
        'Get'
        'List'
        'Update'
        'Create'
        'Import'
        'Delete'
        'Recover'
        'Backup'
        'Restore'
        'GetRotationPolicy'
        'SetRotationPolicy'
        'Rotate'
        'Encrypt'
        'Decrypt'
        'UnwrapKey'
        'WrapKey'
        'Verify'
        'Sign'
        'Purge'
        'Release'
      ]
      secrets: [
        'Get'
        'List'
        'Set'
        'Delete'
        'Recover'
        'Backup'
        'Restore'
        'Purge'
      ]
    }
  }
}
