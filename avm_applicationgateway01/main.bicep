targetScope = 'subscription'

param config object
param environment string
param location string = deployment().location
param addressPrefixes array
param subnets array
param utc string = utcNow()
param timestamp int = dateTimeToEpoch(utc)

var prefix = toLower('${config.product}-sys-${environment}-${config.location}')
var prefixSt = toLower('${config.product}-st-${environment}-${config.location}')
var prefixWaf = toLower('${config.product}-waf-${environment}-${config.location}')
var prefixCert = toLower('${config.product}-cert-${environment}-${config.location}')

var subnet = toObject(
  reference(
    resourceId(subscription().subscriptionId, rg.name, 'Microsoft.Network/virtualNetworks', 'vnet-${prefix}-01'),
    '2023-11-01'
  ).subnets,
  subnet => subnet.name
)

var subnetsAndNsg = [
  for snet in subnets: union(
    snet,
    snet.name != 'GatewaySubnet'
      ? {
          networkSecurityGroupResourceId: resourceId(
            subscription().subscriptionId,
            rg.name,
            'Microsoft.Network/networkSecurityGroups',
            'nsg-${snet.name}'
          )
        }
      : {}
  )
]

var domains = [
  'privatelink.vaultcore.azure.net'
  'privatelink.blob.${az.environment().suffixes.storage}'
  'privatelink.file.${az.environment().suffixes.storage}'
  'privatelink.azurewebsites.net'
]

var myIp = '188.150.11.11'

func pdnszId(rgName string, pdnsz string) string =>
  resourceId(subscription().subscriptionId, rgName, 'Microsoft.Network/privateDnsZones', pdnsz)

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${prefix}-01'
  location: location
  tags: union(config.tags, {
    System: config.product
  })
}

resource rgSt 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${prefixSt}-01'
  location: location
  tags: union(config.tags, {
    System: config.product
  })
}

resource rgCert 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${prefixCert}-01'
  location: location
  tags: union(config.tags, {
    System: config.product
  })
}

module id 'br:mcr.microsoft.com/bicep/avm/res/managed-identity/user-assigned-identity:0.4.0' = {
  scope: rg
  name: 'id'
  params: {
    name: 'id-${prefix}-01'
  }
}

module nsgM 'br:mcr.microsoft.com/bicep/avm/res/network/network-security-group:0.5.0' = [
  for nsg in subnets: if (nsg.name != 'GatewaySubnet') {
    name: 'nsg-${nsg.name}'
    scope: rg
    params: {
      name: 'nsg-${nsg.name}'
      securityRules: nsg.securityRules
    }
  }
]

module logM 'br:mcr.microsoft.com/bicep/avm/res/operational-insights/workspace:0.7.0' = {
  scope: rg
  name: 'log'
  params: {
    name: 'log-${prefix}-01'
    skuName: 'PerGB2018'
  }
}

module appiM 'br:mcr.microsoft.com/bicep/avm/res/insights/component:0.4.1' = {
  scope: rg
  name: 'appi'
  params: {
    name: 'appi-${prefix}-01'
    workspaceResourceId: logM.outputs.resourceId
  }
}

module vnetM 'br:mcr.microsoft.com/bicep/avm/res/network/virtual-network:0.4.0' = {
  scope: rg
  name: 'vnet'
  params: {
    addressPrefixes: addressPrefixes
    name: 'vnet-${prefix}-01'
    subnets: subnetsAndNsg
  }
}

module pdnszM 'br:mcr.microsoft.com/bicep/avm/res/network/private-dns-zone:0.6.0' = [
  for dns in domains: {
    scope: rg
    name: dns
    params: {
      name: dns
      virtualNetworkLinks: [
        {
          virtualNetworkResourceId: vnetM.outputs.resourceId
          registrationEnabled: false
        }
      ]
    }
  }
]

module kv 'br:mcr.microsoft.com/bicep/avm/res/key-vault/vault:0.9.0' = {
  scope: rgCert
  name: 'kv'
  params: {
    name: 'kv-${prefixCert}-01'
    enablePurgeProtection: false
    enableRbacAuthorization: false
    enableSoftDelete: false
    enableVaultForDeployment: false
    enableVaultForDiskEncryption: false
    enableVaultForTemplateDeployment: false
    accessPolicies: [
      {
        objectId: '0d483cbc-6f65-4e78-ab29-44c39c80d135'
        permissions: {
          secrets: [
            'all'
          ]
        }
      }
    ]
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      ipRules: [
        {
          value: myIp
        }
      ]
    }
    privateEndpoints: [
      {
        subnetResourceId: subnet['snet-pep'].id
        name: toLower('pep-kv-${prefixCert}-01')
        customNetworkInterfaceName: toLower('nic-kv-${prefixCert}-01')
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: pdnszId(rg.name, 'privatelink.vaultcore.azure.net')
            }
          ]
        }
      }
    ]
  }
}

module agw 'agw.bicep' = {
  name: 'agw-${timestamp}'
  params: {
    location: location
    tags: config.tags
    logId: logM.outputs.resourceId
    prefix: prefixWaf
    prefixCert: prefixCert
    privateIPAddress: '10.10.1.5'
    snetId: subnet['snet-agw'].id
    snetName: 'snet-agw'
    sslCertificates: [
      'my-wesite-com'
    ]
    sites: [
      {
        name: 'pay-app'
        hostname: 'pay-utv.abcsolutions.com'
        sslCertificate: ''
        probePath: '/api/health'
        pickHostNameFromBackendAddress: false
        privateListener: false
        backendAddresses: [
          {
            fqdn: 'app-invoicepayment-hbr-dev-we-01.azurewebsites.net'
          }
        ]
        waf: {
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-932-APPLICATION-ATTACK-RCE'
              rules: [
                {
                  ruleId: '932100'
                  state: 'Enabled'
                  action: 'Log'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
              rules: [
                {
                  ruleId: '942430'
                  state: 'Enabled'
                  action: 'Log'
                }
                {
                  ruleId: '942440'
                  state: 'Enabled'
                  action: 'Log'
                }
              ]
            }
          ]
          customRules: []
        }
      }
    ]
    pathRules: [
      {
        name: 'oauth'
        site: 'extapi-app'
        probePath: '/2e6c1234-9b2a-43db-a773-fd13c82e2f9d/b2c_1a_ClientCredentialsFlow/v2.0/.well-known/openid-configuration'
        pickHostNameFromBackendAddress: true
        paths: [
          '/oauth2/v2.0/token'
        ]
        backendAddresses: [
          {
            fqdn: 'login.abcsolutions.com'
          }
        ]
        rewriteRuleSet: {
          actionSet: {
            urlConfiguration: {
              modifiedPath: '/abcauth.onmicrosoft.com/B2C_1A_ClientCredentialsFlow/oauth2/v2.0/token'
              modifiedQueryString: '?scope=https%3A%2F%2Fabcauth.onmicrosoft.com%2Fapi%2F.default'
              reroute: false
            }
          }
        }
        waf: {
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-931-APPLICATION-ATTACK-RFI'
              rules: [
                {
                  ruleId: '931130'
                  state: 'Enabled'
                  action: 'Log'
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
