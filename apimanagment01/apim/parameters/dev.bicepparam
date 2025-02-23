using '../main.bicep'

param environment = 'dev'
param tags = {
  Product: 'Common Infrastructure'
  Environment: 'Development'
  CostCenter: '9100'
}
param config = {
  product: 'infra'
  location: 'we'
}
var addressPrefixes = ['10.10.0.0/20']
var subnets = {
  GatewaySubnet: cidrSubnet(addressPrefixes[0], 26, 0)
  AzureFirewallSubnet: cidrSubnet(addressPrefixes[0], 26, 1)
  AzureBastionSubnet: cidrSubnet(addressPrefixes[0], 26, 2)
  'snet-mgmt': cidrSubnet(addressPrefixes[0], 26, 3)
  'snet-app': cidrSubnet(addressPrefixes[0], 26, 4)
  'snet-pep': cidrSubnet(addressPrefixes[0], 26, 5)
  'snet-apim': cidrSubnet(addressPrefixes[0], 26, 6)
}
param apim = {
  initialDeploy: true
  sku: 'Developer'
  capacity: 1
  publisherName: 'ABCSE'
  publisherEmail: 'karol.sek@abc.se'
  type: 'External'
  customProperties: {
    'Microsoft.WindowsAzure.ApiManagement.Gateway.Protocols.Server.Http2': true
    'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10': false
    'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11': false
    'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Ssl30': false
    'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10': false
    'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11': false
    'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30': false
    'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA': false
    'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA': false
    'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_GCM_SHA256': false
    'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA256': false
    'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA256': false
    'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA': false
    'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA': false
    'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168': false
  }
}

param apis = [
  // {
  //   name: 'ticket-api'
  //   displayName: 'Ticket API'
  //   subscriptionRequired: false
  //   url: 'https://app-labb-api-dev-we-01.azurewebsites.net/'
  //   path: 'ticket'
  //   swaggerPath: 'swagger/v1/swagger.json'
  //   isCurrent: true
  //   roles: '''
  //     <value>access.admin</value>
  //     <value>access.user</value>
  //     <value>User</value>
  //   '''
  // }
  // {
  //   name: 'ticket-api-03'
  //   displayName: 'Ticket API v3'
  //   subscriptionRequired: false
  //   url: 'https://app-labb-api-dev-we-03.azurewebsites.net/'
  //   path: 'EntraId'
  //   swaggerPath: 'swagger/v1/swagger.json'
  //   isCurrent: true
  //   roles: '''
  //     <value>role.one</value>
  //   '''
  // }
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
      name: 'snet-app'
      addressPrefix: subnets['snet-app']
      delegation: 'Microsoft.Web/serverFarms'
    }
    {
      name: 'snet-pep'
      addressPrefix: subnets['snet-pep']
    }
    {
      name: 'snet-apim'
      addressPrefix: subnets['snet-apim']
      rules: [
        {
          name: 'nsgsr-allow-apim-inbound'
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
          name: 'nsgsr-allow-management_endpoint-inbound'
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
          name: 'nsgsr-allow-management-redis-cache-inbound'
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
          name: 'nsgsr-allow-management-rate-limit-inbound'
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
          name: 'nsgsr-allow-management-load-balancer-inbound'
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
          name: 'nsgsr-allow-management-azure-sql-outbound'
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
          name: 'nsgsr-allow-management-event-hub-outbound'
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
          name: 'nsgsr-allow-management-redis-cache-outbound'
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
          name: 'nsgsr-allow-management-rate-limit-outbound'
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
          name: 'nsgsr-allow-management-file-share-outbound'
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
          name: 'nsgsr-allow-management-azure-monitor-outbound'
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
          name: 'nsgsr-allow-management-smtp-relay-outbound'
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
          name: 'nsgsr-allow-management-active-directory-outbound'
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
          name: 'nsgsr-allow-management-storage-outbound'
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
          name: 'nsgsr-allow-management-monitoring-logs-outbound'
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
          name: 'nsgsr-allow-management-key-vault-outbound'
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
          name: 'nsgsr-allow-internet-outbound'
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
          name: 'nsgsr-allow-all-spokes-outbound'
          properties: {
            description: 'Allow API Management service control plane access to all spokes'
            protocol: 'Tcp'
            sourcePortRange: '*'
            sourceAddressPrefix: '*'
            destinationAddressPrefix: '10.100.0.0/16'
            access: 'Allow'
            priority: 370
            direction: 'Outbound'
            destinationPortRange: '*'
          }
        }
      ]
    }
  ]
}
