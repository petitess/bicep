using 'main.bicep'

param environment = 'dev'
param config = {
  product: 'infra'
  location: 'sc'
  tags: {
    Product: 'Common Infrastructure'
    Environment: 'Development'
    CostCenter: '54321'
  }
  vnet: {
    addressPrefixes: [
      '10.100.6.0/24'
      '10.100.10.0/24'
    ]
    subnets: [
      {
        name: 'snet-agw'
        addressPrefix: '10.100.6.0/24'
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
              destinationPortRange: '*'
              protocol: '*'
              priority: 200
              direction: 'Inbound'
            }
          }
        ]
        defaultRules: 'Inbound'
      }
      {
        name: 'snet-apim'
        addressPrefix: '10.100.10.0/27'
        delegation: 'Microsoft.ApiManagement/service'
        serviceEndpoints: [
          {
            service: 'Microsoft.Web'
          }
          {
            service: 'Microsoft.KeyVault'
          }
        ]
        routes: []
        rules: []
      }
      {
        name: 'snet-pep'
        addressPrefix: '10.100.10.32/27'
      }
      {
        name: 'snet-mgmt'
        addressPrefix: '10.100.10.64/27'
      }
    ]
  }
  agw: {
    firewallConfiguration: {
      enabled: true
      firewallMode: 'Prevention'
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.2'
      requestBodyCheck: true
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 100
      ruleGroupOverrides: []
    }
    sslCertificates: [
      'xxxsolutions-com'
    ]
    sites: [
      {
        name: 'access-app'
        hostname: 'access.xxxsolutions.com'
        sslCertificate: 'xxxsolutions-com'
        pickHostNameFromBackendAddress: true
        probePath: '/health'
        backendAddresses: [
          {
            fqdn: 'app-prod-we-01.azurewebsites.net'
          }
        ]
        waf: {
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-932-APPLICATION-ATTACK-RCE'
              rules: [
                {
                  ruleId: '932100'
                  state: 'Disabled'
                }
                {
                  ruleId: '932105'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
              rules: [
                {
                  ruleId: '942430'
                  state: 'Disabled'
                }
                {
                  ruleId: '942440'
                  state: 'Disabled'
                }
                {
                  ruleId: '942450'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
      {
        name: 'academy-admin-xxxsolutions-app'
        hostname: 'academy.xxxsolutions.com'
        sslCertificate: 'xxxsolutions-com'
        probePath: '/health'
        pickHostNameFromBackendAddress: false
        backendAddresses: [
          {
            fqdn: 'academy.xxxsolutions.com'
          }
        ]
        waf: {
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-931-APPLICATION-ATTACK-RFI'
              rules: [
                {
                  ruleId: '931130'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-932-APPLICATION-ATTACK-RCE'
              rules: [
                {
                  ruleId: '932100'
                  state: 'Disabled'
                }
                {
                  ruleId: '932105'
                  state: 'Disabled'
                }
                {
                  ruleId: '932110'
                  state: 'Disabled'
                }
                {
                  ruleId: '932115'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
              rules: [
                {
                  ruleId: '942190'
                  state: 'Disabled'
                }
                {
                  ruleId: '942200'
                  state: 'Disabled'
                }
                {
                  ruleId: '942260'
                  state: 'Disabled'
                }
                {
                  ruleId: '942330'
                  state: 'Disabled'
                }
                {
                  ruleId: '942340'
                  state: 'Disabled'
                }
                {
                  ruleId: '942370'
                  state: 'Disabled'
                }
                {
                  ruleId: '942430'
                  state: 'Disabled'
                }
                {
                  ruleId: '942440'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
    ]
  }
}
