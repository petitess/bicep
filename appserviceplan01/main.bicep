targetScope = 'subscription'

param tags object
param env string
param timestamp int = dateTimeToEpoch(utcNow())
param location string = deployment().location
param vnet object
param storageAccounts ({
  name: string
  resourceGroup: string
  skuName: (
    | 'Premium_LRS'
    | 'Premium_ZRS'
    | 'Standard_GRS'
    | 'Standard_GZRS'
    | 'Standard_LRS'
    | 'Standard_RAGRS'
    | 'Standard_RAGZRS'
    | 'Standard_ZRS')
  isSftpEnabled: bool
  publicAccess: ('Disabled' | 'Enabled')
  allowedIPs: array
  privateEndpoints: ({ blob: string?, file: string?, table: string?, queue: string?, web: string?, dfs: string? })
  shares: array
  containers: array
  rbac: ({
    role: (
      | 'Storage Queue Data Contributor'
      | 'Storage Table Data Contributor'
      | 'Storage Blob Data Contributor'
      | 'Storage File Data Privileged Contributor')
    principalId: string
  })[]?
})[]

var unique = take(uniqueString(subscription().subscriptionId), 3)
var prefix = toLower('${unique}-${env}')
var domains = [
  'privatelink.blob.${environment().suffixes.storage}'
  'privatelink.azurewebsites.net'
  'privatelink.servicebus.windows.net'
]
var snet = toObject(vnetE.properties.subnets, subnet => subnet.name)
var allowFromAgw = [
  {
    ipAddress: '1.1.78.36/32'
    action: 'Allow'
    tag: 'Default'
    priority: 100
    name: 'Allow_from_AGW'
    description: 'Allow traffic only from this IP'
  }
]

func name(res string, instance string) string => '${res}-${prefix}-${instance}'

resource vnetE 'Microsoft.Network/virtualNetworks@2024-07-01' existing = {
  name: name('vnet', '01')
  scope: resourceGroup(name('rg-vnet', '01'))
  dependsOn: [
    vnetM
    rg
  ]
}

resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: name('rg-vnet', '01')
  location: location
  tags: tags
}

resource rgSt 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: 'rg-st-${env}-01'
  location: location
  tags: tags
}

resource rgApp 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: name('rg-app', '01')
  location: location
  tags: union(tags, {
    ApplicationName: 'komet'
  })
}

resource rgRelay 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: name('rg-relay', '01')
  location: location
  tags: tags
}

module vnetM 'vnet.bicep' = {
  scope: rg
  params: {
    addressPrefixes: vnet.addressPrefixes
    name: name('vnet', '01')
    location: location
    subnets: vnet.subnets
    dnsServers: []
  }
}

module pdnszM 'pdnsz.bicep' = [
  for (domain, i) in domains: {
    name: 'pdnsz-${split(domain, '.')[1]}'
    scope: rg
    params: {
      name: domain
      vnetName: vnetM.outputs.name
      vnetId: vnetM.outputs.id
    }
  }
]

module st 'st.bicep' = [
  for (st, i) in storageAccounts: {
    name: '${st.name}-${timestamp}'
    scope: resourceGroup(st.resourceGroup)
    params: {
      name: st.name
      location: location
      skuName: st.skuName
      isSftpEnabled: st.isSftpEnabled
      publicAccess: st.publicAccess
      allowedIPs: st.allowedIPs
      snetPepId: resourceId(
        subscription().subscriptionId,
        rg.name,
        'Microsoft.Network/virtualNetworks/subnets',
        vnetM.outputs.name,
        'snet-pep'
      )
      privateEndpoints: items(st.privateEndpoints)
      privateDnsZoneRg: rg.name
      shares: st.shares
      containers: st.containers
      rbac: st.?rbac ?? []
    }
  }
]

module aspM 'asp.bicep' = {
  scope: rg
  params: {
    name: name('asp', '01')
    kind: 'app'
    sku: {
      name: 'P0v3'
      tier: 'Premium0V3'
    }
  }
}

module relayM 'relay.bicep' = {
  scope: rgRelay
  params: {
    relayConnectionName: name('con', '01')
    relayName: name('relay', '01')
    relayRuleName: 'rule01'
    snetPepId: snet['snet-pep'].id
    ipAddress: '10.10.1.70'
    privateDnsZoneId: resourceId(
      subscription().subscriptionId,
      rg.name,
      'Microsoft.Network/privateDnsZones',
      'privatelink.servicebus.windows.net'
    )
  }
}

module appM 'app.bicep' = {
  scope: rgApp
  params: {
    name: name('app', '01')
    kind: 'app'
    tags: tags
    serverFarmResourceId: aspM.outputs.id
    virtualNetworkSubnetOutboundResourceId: snet['snet-app'].id
    publicNetworkAccess: 'Disabled'
    enableBasicAuthFtp: true
    enableBasicAuthScm: true
    managedIdentities: {
      systemAssigned: true
    }
    configAppsettings: {
      WEBSITE_DNS_SERVER: '10.1.2.1'
      WEBSITE_ALT_DNS_SERVER: '10.1.2.11'
      WEBSITE_TIME_ZONE: 'Central European Standard Time'
      APPLICATIONINSIGHTS_CONNECTION_STRING: ''
      ApplicationInsightsAgent_EXTENSION_VERSION: '~2'
      WEBSITE_RUN_FROM_PACKAGE: '0'
      WEBSITE_ENABLE_SYNC_UPDATE_SITE: 'true'
      SLOT_NAME: toUpper(env)
      WEBSITE_LOAD_CERTIFICATES: '*'
      WEBJOBS_IDLE_TIMEOUT: '3600'
    }
    configWeb: {
      minTlsVersion: '1.2'
      scmMinTlsVersion: '1.2'
      healthCheckPath: '/health/index.html'
    }
    siteConfig: {
      alwaysOn: true
      minimumElasticInstanceCount: 1
    }
    privateEndpoints: {
      sites: '10.10.1.68'
      'sites-stage': '10.10.1.69'
    }
    virtualNetworkSubnetInboundResourceId: snet['snet-pep'].id
    privateDnsZoneId: resourceId(
      subscription().subscriptionId,
      rg.name,
      'Microsoft.Network/privateDnsZones',
      'privatelink.azurewebsites.net'
    )
    rbac: [
      'Storage Blob Data Contributor'
    ]
    hybridConnectionRelay: {
      hostname: name('relay', '01')
      port: 22
      relayName: name('relay', '01')
      relayArmUri: relayM.outputs.conectionId
      sendKeyName: relayM.outputs.keyName1
      serviceBusNamespace: name('relay', '01')
      sendKeyValue: relayM.outputs.keyValue1
      serviceBusSuffix: '.servicebus.windows.net'
    }
    SLOT: {
      name: 'stage'
      tags: tags
      publicNetworkAccess: 'Disabled'
      httpsOnly: true
      enableBasicAuthFtp: true
      enableBasicAuthScm: true
      configAppsettings: {
        WEBSITE_DNS_SERVER: '10.1.2.11'
        WEBSITE_ALT_DNS_SERVER: '10.1.2.12'
        WEBSITE_TIME_ZONE: 'Central European Standard Time'
        WEBSITE_RUN_FROM_PACKAGE: '0'
        WEBSITE_ENABLE_SYNC_UPDATE_SITE: 'true'
        SLOT_NAME: 'STAGE'
        WEBSITE_LOAD_CERTIFICATES: '*'
      }
      siteConfig: {
        alwaysOn: true
        ipSecurityRestrictions: allowFromAgw
      }
      configWeb: {
        minTlsVersion: '1.2'
        healthCheckPath: '/health/index.html'
      }
    }
  }
}
