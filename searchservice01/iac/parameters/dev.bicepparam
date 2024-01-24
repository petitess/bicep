using '../main.bicep'

param environment = 'dev'
param config = {
  product: 'standards'
  shortProduct: 'std'
  system: 'standard'
  shortSystem: 'std'
  location: 'we'
  tags: {
    Product: 'Standard'
    Environment: 'Development'
    CostCenter: '1010'
  }
  database: {
    sku: {
      name: 'Basic'
      tier: 'Basic'
      capacity: 5
    }
    servername: 'sql-standards-${environment}-01'
    dbname: 'sqldb-standards-standard-dev-we-01'
  }
  searchService: {
    skuName: 'basic'
  }
  vnet: {
    addressPrefixes: [
      '10.100.40.0/24'
    ]
    subnets: [
      {
        name: 'snet-standards-std-app-inbound'
        addressPrefix: '10.100.40.0/28'
        rules: [
          {
            name: 'nsgsr-allow-infra-vmss-inbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.10.64/27'
              sourcePortRange: '*'
              destinationAddressPrefix: '10.100.40.0/28'
              destinationPortRange: 443
              protocol: 'Tcp'
              priority: 100
              direction: 'Inbound'
            }
          }
          {
            name: 'nsgsr-allow-infra-agw-inbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.6.0/24'
              sourcePortRange: '*'
              destinationAddressPrefix: '10.100.40.0/28'
              destinationPortRange: 443
              protocol: 'Tcp'
              priority: 200
              direction: 'Inbound'
            }
          }
        ]
      }
      {
        name: 'snet-standards-std-func-inbound'
        addressPrefix: '10.100.40.16/28'
        rules: [
          {
            name: 'nsgsr-allow-infra-vmss-inbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.10.64/27'
              sourcePortRange: '*'
              destinationAddressPrefix: '10.100.40.16/28'
              destinationPortRange: 443
              protocol: 'Tcp'
              priority: 100
              direction: 'Inbound'
            }
          }
        ]
      }
      {
        name: 'snet-standards-std-common-inbound'
        addressPrefix: '10.100.40.32/28'
        rules: []
      }
      {
        name: 'snet-standards-std-app-outbound'
        addressPrefix: '10.100.40.48/28'
        rules: [
          {
            name: 'nsgsr-allow-https-we-outbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.40.48/28'
              sourcePortRange: '*'
              destinationAddressPrefix: 'Internet'
              destinationPortRange: 443
              protocol: '*'
              priority: 100
              direction: 'Outbound'
            }
          }
          {
            name: 'nsgsr-allow-ampls-outbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.40.48/28'
              sourcePortRange: '*'
              destinationAddressPrefix: '10.100.9.160/27'
              destinationPortRange: 443
              protocol: '*'
              priority: 200
              direction: 'Outbound'
            }
          }
          {
            name: 'nsgsr-allow-snet-common-inbound-https-outbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.40.48/28'
              sourcePortRange: '*'
              destinationAddressPrefix: '10.100.40.32/28'
              destinationPortRange: 443
              protocol: '*'
              priority: 300
              direction: 'Outbound'
            }
          }
        ]
        delegation: 'Microsoft.Web/serverFarms'
      }
      {
        name: 'snet-standards-std-func-outbound'
        addressPrefix: '10.100.40.64/28'
        rules: [
          {
            name: 'nsgsr-allow-https-we-outbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.40.64/28'
              sourcePortRange: '*'
              destinationAddressPrefix: 'Internet'
              destinationPortRange: 443
              protocol: '*'
              priority: 100
              direction: 'Outbound'
            }
          }
          {
            name: 'nsgsr-allow-ampls-outbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.40.64/28'
              sourcePortRange: '*'
              destinationAddressPrefix: '10.100.9.160/27'
              destinationPortRange: 443
              protocol: '*'
              priority: 200
              direction: 'Outbound'
            }
          }
          {
            name: 'nsgsr-allow-sbns-amqp-we-outbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.40.64/28'
              sourcePortRange: '*'
              destinationAddressPrefix: 'Internet'
              destinationPortRange: '5671-5672'
              protocol: '*'
              priority: 201
              direction: 'Outbound'
            }
          }
          {
            name: 'nsgsr-allow-snet-common-inbound-https-outbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.40.64/28'
              sourcePortRange: '*'
              destinationAddressPrefix: '10.100.40.32/28'
              destinationPortRange: 443
              protocol: '*'
              priority: 300
              direction: 'Outbound'
            }
          }
        ]
        delegation: 'Microsoft.Web/serverFarms'
      }
      {
        name: 'snet-standards-shop-app-inbound'
        addressPrefix: '10.100.40.96/28'
        rules: [
          {
            name: 'nsgsr-allow-infra-vmss-inbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.10.64/27'
              sourcePortRange: '*'
              destinationAddressPrefix: '10.100.40.96/28'
              destinationPortRange: 443
              protocol: 'Tcp'
              priority: 100
              direction: 'Inbound'
            }
          }
          {
            name: 'nsgsr-allow-infra-agw-inbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.6.0/24'
              sourcePortRange: '*'
              destinationAddressPrefix: '10.100.40.96/28'
              destinationPortRange: 443
              protocol: 'Tcp'
              priority: 200
              direction: 'Inbound'
            }
          }
        ]
      }
      {
        name: 'snet-standards-shop-func-inbound'
        addressPrefix: '10.100.40.112/28'
        rules: [
          {
            name: 'nsgsr-allow-infra-vmss-inbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.10.64/27'
              sourcePortRange: '*'
              destinationAddressPrefix: '10.100.40.112/28'
              destinationPortRange: 443
              protocol: 'Tcp'
              priority: 100
              direction: 'Inbound'
            }
          }
        ]
      }
      {
        name: 'snet-standards-shop-common-inbound'
        addressPrefix: '10.100.40.128/28'
        rules: []
      }
      {
        name: 'snet-standards-shop-app-outbound'
        addressPrefix: '10.100.40.144/28'
        rules: [
          {
            name: 'nsgsr-allow-https-we-outbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.40.144/28'
              sourcePortRange: '*'
              destinationAddressPrefix: 'Internet'
              destinationPortRange: 443
              protocol: '*'
              priority: 100
              direction: 'Outbound'
            }
          }
          {
            name: 'nsgsr-allow-ampls-outbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.40.144/28'
              sourcePortRange: '*'
              destinationAddressPrefix: '10.100.9.160/27'
              destinationPortRange: 443
              protocol: '*'
              priority: 200
              direction: 'Outbound'
            }
          }
          {
            name: 'nsgsr-allow-snet-common-inbound-https-outbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.40.144/28'
              sourcePortRange: '*'
              destinationAddressPrefix: '10.100.40.128/28'
              destinationPortRange: 443
              protocol: '*'
              priority: 300
              direction: 'Outbound'
            }
          }
        ]
        delegation: 'Microsoft.Web/serverFarms'
      }
      {
        name: 'snet-standards-shop-func-outbound'
        addressPrefix: '10.100.40.160/28'
        rules: [
          {
            name: 'nsgsr-allow-https-we-outbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.40.160/28'
              sourcePortRange: '*'
              destinationAddressPrefix: 'Internet'
              destinationPortRange: 443
              protocol: '*'
              priority: 100
              direction: 'Outbound'
            }
          }
          {
            name: 'nsgsr-allow-ampls-outbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.40.160/28'
              sourcePortRange: '*'
              destinationAddressPrefix: '10.100.9.160/27'
              destinationPortRange: 443
              protocol: '*'
              priority: 200
              direction: 'Outbound'
            }
          }
          {
            name: 'nsgsr-allow-sbns-amqp-we-outbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.40.160/28'
              sourcePortRange: '*'
              destinationAddressPrefix: 'Internet'
              destinationPortRange: '5671-5672'
              protocol: '*'
              priority: 201
              direction: 'Outbound'
            }
          }
          {
            name: 'nsgsr-allow-snet-common-inbound-https-outbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.40.160/28'
              sourcePortRange: '*'
              destinationAddressPrefix: '10.100.40.128/28'
              destinationPortRange: 443
              protocol: '*'
              priority: 300
              direction: 'Outbound'
            }
          }
        ]
        delegation: 'Microsoft.Web/serverFarms'
      }
      {
        name: 'snet-standards-prolog-app-inbound'
        addressPrefix: '10.100.40.176/28'
        rules: [
          {
            name: 'nsgsr-allow-infra-vmss-inbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.10.64/27'
              sourcePortRange: '*'
              destinationAddressPrefix: '10.100.40.176/28'
              destinationPortRange: 443
              protocol: 'Tcp'
              priority: 100
              direction: 'Inbound'
            }
          }
          {
            name: 'nsgsr-allow-infra-agw-inbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.6.0/24'
              sourcePortRange: '*'
              destinationAddressPrefix: '10.100.40.176/28'
              destinationPortRange: 443
              protocol: 'Tcp'
              priority: 200
              direction: 'Inbound'
            }
          }
        ]
      }
      {
        name: 'snet-standards-prolog-func-inbound'
        addressPrefix: '10.100.40.192/28'
        rules: [
          {
            name: 'nsgsr-allow-infra-vmss-inbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.10.64/27'
              sourcePortRange: '*'
              destinationAddressPrefix: '10.100.40.192/28'
              destinationPortRange: 443
              protocol: 'Tcp'
              priority: 100
              direction: 'Inbound'
            }
          }
        ]
      }
      {
        name: 'snet-standards-prolog-common-inbound'
        addressPrefix: '10.100.40.208/28'
        rules: [
          {
            name: 'nsgsr-allow-snet-https-outbound-common-inbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.40.224/28'
              sourcePortRange: '*'
              destinationAddressPrefix: '10.100.40.208/28'
              destinationPortRange: 443
              protocol: '*'
              priority: 100
              direction: 'Inbound'
            }
          }
        ]
      }
      {
        name: 'snet-standards-prolog-app-outbound'
        addressPrefix: '10.100.40.224/28'
        rules: [
          {
            name: 'nsgsr-allow-https-we-outbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.40.224/28'
              sourcePortRange: '*'
              destinationAddressPrefix: 'Internet'
              destinationPortRange: 443
              protocol: '*'
              priority: 100
              direction: 'Outbound'
            }
          }
          {
            name: 'nsgsr-allow-ampls-outbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.40.224/28'
              sourcePortRange: '*'
              destinationAddressPrefix: '10.100.9.160/27'
              destinationPortRange: 443
              protocol: '*'
              priority: 200
              direction: 'Outbound'
            }
          }
          {
            name: 'nsgsr-allow-snet-common-inbound-https-outbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.40.224/28'
              sourcePortRange: '*'
              destinationAddressPrefix: '10.100.40.208/28'
              destinationPortRange: 443
              protocol: '*'
              priority: 300
              direction: 'Outbound'
            }
          }
        ]
        delegation: 'Microsoft.Web/serverFarms'
      }
      {
        name: 'snet-standards-prolog-func-outbound'
        addressPrefix: '10.100.40.240/28'
        rules: [
          {
            name: 'nsgsr-allow-https-we-outbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.40.240/28'
              sourcePortRange: '*'
              destinationAddressPrefix: 'Internet'
              destinationPortRange: 443
              protocol: '*'
              priority: 100
              direction: 'Outbound'
            }
          }
          {
            name: 'nsgsr-allow-ampls-outbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.40.240/28'
              sourcePortRange: '*'
              destinationAddressPrefix: '10.100.9.160/27'
              destinationPortRange: 443
              protocol: '*'
              priority: 200
              direction: 'Outbound'
            }
          }
          {
            name: 'nsgsr-allow-sbns-amqp-we-outbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.40.240/28'
              sourcePortRange: '*'
              destinationAddressPrefix: 'Internet'
              destinationPortRange: '5671-5672'
              protocol: '*'
              priority: 201
              direction: 'Outbound'
            }
          }
          {
            name: 'nsgsr-allow-snet-common-inbound-https-outbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.40.240/28'
              sourcePortRange: '*'
              destinationAddressPrefix: '10.100.40.208/28'
              destinationPortRange: 443
              protocol: '*'
              priority: 300
              direction: 'Outbound'
            }
          }
        ]
        delegation: 'Microsoft.Web/serverFarms'
      }
    ]
  }
}

