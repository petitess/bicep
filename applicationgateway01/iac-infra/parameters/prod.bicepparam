using '../main.bicep'

param env = 'prod'
param tags = {
  product: 'app'
}

var myIP = '1.1.1.1'
var addressPrefixes = ['10.20.0.0/20']

var subnets = {
  GatewaySubnet: cidrSubnet(addressPrefixes[0], 26, 0)
  AzureFirewallSubnet: cidrSubnet(addressPrefixes[0], 26, 1)
  AzureBastionSubnet: cidrSubnet(addressPrefixes[0], 26, 2)
  'snet-mgmt': cidrSubnet(addressPrefixes[0], 26, 3)
  'snet-agw': cidrSubnet(addressPrefixes[0], 26, 4)
  'snet-pep': cidrSubnet(addressPrefixes[0], 26, 5)
  'snet-apim': cidrSubnet(addressPrefixes[0], 26, 6)
}

param keyVaults = [
  {
    name: 'kvcertabcprod01'
    rgName: 'rg-vnet-sys-prod-01'
    publicNetworkAccess: 'Allow'
    allowIps: []
    enablePurgeProtection: true
    ipAddress: '10.20.1.70'
  }
]

param vnet = {
  addressPrefixes: addressPrefixes
  subnets: [
    {
      name: 'GatewaySubnet'
      addressPrefix: subnets.GatewaySubnet
    }
    {
      name: 'AzureFirewallSubnet'
      addressPrefix: subnets.AzureFirewallSubnet
    }
    {
      name: 'AzureBastionSubnet'
      addressPrefix: subnets.AzureBastionSubnet
    }
    {
      name: 'snet-mgmt'
      addressPrefix: subnets['snet-mgmt']
      rules: [
        {
          name: 'Allow_Inbound_RDP'
          properties: {
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRange: '3389'
            sourceAddressPrefix: 'Internet'
            destinationAddressPrefix: '*'
            access: 'Allow'
            priority: 200
            direction: 'Inbound'
          }
        }
        {
          name: 'Allow_Inbound_subnet'
          properties: {
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRange: '*'
            sourceAddressPrefix: '10.0.1.128/25'
            destinationAddressPrefix: '10.0.1.128/25'
            access: 'Allow'
            priority: 300
            direction: 'Inbound'
          }
        }
        {
          name: 'Allow_Outbound_subnet'
          properties: {
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRange: '*'
            sourceAddressPrefix: '10.0.1.128/25'
            destinationAddressPrefix: '10.0.1.128/25'
            access: 'Allow'
            priority: 100
            direction: 'Outbound'
          }
        }
      ]
    }
    {
      name: 'snet-agw'
      addressPrefix: subnets['snet-agw']
      rules: [
        {
          name: 'Allow_Inbound_internet'
          properties: {
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRanges: [
              '443'
              '80'
            ]
            sourceAddressPrefix: '*'
            destinationAddressPrefix: '*'
            access: 'Allow'
            priority: 900
            direction: 'Inbound'
          }
        }
        {
          name: 'Allow_Inbound_internet'
          properties: {
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRange: '65200-65535'
            sourceAddressPrefix: '*'
            destinationAddressPrefix: '*'
            access: 'Allow'
            priority: 1000
            direction: 'Inbound'
          }
        }
        {
          name: 'Allow_Outbound_Internet'
          properties: {
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRange: '*'
            sourceAddressPrefix: '*'
            destinationAddressPrefix: 'Internet'
            access: 'Allow'
            priority: 4095
            direction: 'Outbound'
          }
        }
      ]
    }
    {
      name: 'snet-pep'
      addressPrefix: subnets['snet-pep']
    }
    {
      name: 'snet-apim'
      addressPrefix: subnets['snet-apim']
      delegation: 'Microsoft.Web/serverFarms'
      rules: [
         {
          name: 'Allow-apim-inbound'
          properties: {
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '443'
            sourceAddressPrefix: '*'
            destinationAddressPrefix: '*'
            access: 'Allow'
            priority: 310
            direction: 'Inbound'
          }
        }
        {
          name: 'Allow-management_endpoint-inbound'
          properties: {
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '3443'
            sourceAddressPrefix: 'ApiManagement'
            destinationAddressPrefix: 'VirtualNetwork'
            access: 'Allow'
            priority: 320
            direction: 'Inbound'
          }
        }
        {
          name: 'Allow-management-redis-cache-inbound'
          properties: {
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '6381-6383'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'VirtualNetwork'
            access: 'Allow'
            priority: 330
            direction: 'Inbound'
          }
        }
        {
          name: 'Allow-management-rate-limit-inbound'
          properties: {
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '4290'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'VirtualNetwork'
            access: 'Allow'
            priority: 340
            direction: 'Inbound'
          }
        }
        {
          name: 'Allow-management-load-balancer-inbound'
          properties: {
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '6390'
            sourceAddressPrefix: 'AzureLoadBalancer'
            destinationAddressPrefix: 'VirtualNetwork'
            access: 'Allow'
            priority: 350
            direction: 'Inbound'
          }
        }
        {
          name: 'Allow_Inbound_MGMT'
          properties: {
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRange: '443'
            sourceAddressPrefixes: [
              '10.202.7.11/32'
              '10.202.7.12/32'
              '10.202.7.13/32'
            ]
            destinationAddressPrefix: '*'
            access: 'Allow'
            priority: 360
            direction: 'Inbound'
          }
        }
        {
          name: 'Allow-management-azure-sql-outbound'
          properties: {
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '1433'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'Sql'
            access: 'Allow'
            priority: 250
            direction: 'Outbound'
          }
        }
        {
          name: 'Allow-management-event-hub-outbound'
          properties: {
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRange: '5671'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'EventHub'
            access: 'Allow'
            priority: 260
            direction: 'Outbound'
          }
        }
        {
          name: 'Allow-management-redis-cache-outbound'
          properties: {
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '6381-6383'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'VirtualNetwork'
            access: 'Allow'
            priority: 270
            direction: 'Outbound'
          }
        }
        {
          name: 'Allow-management-rate-limit-outbound'
          properties: {
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '4290'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'VirtualNetwork'
            access: 'Allow'
            priority: 280
            direction: 'Outbound'
          }
        }
        {
          name: 'Allow-management-file-share-outbound'
          properties: {
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '445'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'Storage'
            access: 'Allow'
            priority: 290
            direction: 'Outbound'
          }
        }
        {
          name: 'Allow-management-azure-monitor-outbound'
          properties: {
            description: 'API Management logs and metrics for consumption by admins and your IT team are all part of the management plane'
            protocol: 'Tcp'
            sourcePortRange: '*'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'AzureMonitor'
            access: 'Allow'
            priority: 300
            direction: 'Outbound'
            destinationPortRanges: [
              '443'
              '12000'
              '1886'
            ]
          }
        }
        {
          name: 'Allow-management-smtp-relay-outbound'
          properties: {
            description: 'APIM features the ability to generate email traffic as part of the data plane and the management plane'
            protocol: 'Tcp'
            sourcePortRange: '*'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'Internet'
            access: 'Allow'
            priority: 310
            direction: 'Outbound'
            destinationPortRanges: [
              '25'
              '587'
              '25028'
            ]
          }
        }
        {
          name: 'Allow-management-active-directory-outbound'
          properties: {
            description: 'Connect to Azure Active Directory for developer portal authentication or for OAuth 2 flow during any proxy authentication'
            protocol: 'Tcp'
            sourcePortRange: '*'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'AzureActiveDirectory'
            access: 'Allow'
            priority: 320
            direction: 'Outbound'
            destinationPortRanges: [
              '80'
              '443'
            ]
          }
        }
        {
          name: 'Allow-management-storage-outbound'
          properties: {
            description: 'APIM service dependency on Azure blob and Azure table storage'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '443'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'Storage'
            access: 'Allow'
            priority: 330
            direction: 'Outbound'
          }
        }
        {
          name: 'Allow-management-monitoring-logs-outbound'
          properties: {
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '443'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'AzureCloud'
            access: 'Allow'
            priority: 340
            direction: 'Outbound'
          }
        }
        {
          name: 'Allow-management-key-vault-outbound'
          properties: {
            description: 'Allow API Management service control plane access to Azure Key Vault to refresh secrets'
            protocol: 'Tcp'
            sourcePortRange: '*'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'AzureKeyVault'
            access: 'Allow'
            priority: 350
            direction: 'Outbound'
            destinationPortRanges: [
              '443'
            ]
          }
        }
        {
          name: 'Allow-internet-outbound'
          properties: {
            description: 'Allow API Management service control plane access to Internet'
            protocol: 'Tcp'
            sourcePortRange: '*'
            sourceAddressPrefix: '*'
            destinationAddressPrefix: 'Internet'
            access: 'Allow'
            priority: 360
            direction: 'Outbound'
            destinationPortRanges: [
              '443'
            ]
          }
        }
        {
          name: 'Deny_Outbound_All'
          properties: {
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRange: '*'
            sourceAddressPrefix: '*'
            destinationAddressPrefix: '*'
            access: 'Deny'
            priority: 4096
            direction: 'Outbound'
          }
        }
      ]
    }
  ]
}
