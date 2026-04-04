targetScope = 'subscription'

param tags object
param env string
param timestamp int = dateTimeToEpoch(utcNow())
param location string = deployment().location
param vnet object

var unique = take(uniqueString(subscription().subscriptionId), 3)
var prefix = toLower('${unique}-${env}')
var domains = [
  'privatelink.azurewebsites.net'
  'privatelink.azurecr.io'
]
var snet = toObject(vnetE.properties.subnets, subnet => subnet.name)
var ip = '1.1.118.1'
var allowFromIp = [
  {
    ipAddress: '${ip}/32'
    action: 'Allow'
    tag: 'Default'
    priority: 100
    name: 'Allow_from_IP'
    description: 'Allow traffic only from this IP'
  }
]
var registryUrl 'https://acrczrdev01.azurecr.io' | 'https://mcr.microsoft.com' = 'https://mcr.microsoft.com'

func name(res string, instance string) string => '${res}-${prefix}-${instance}'

resource vnetE 'Microsoft.Network/virtualNetworks@2025-05-01' existing = {
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

module aseM 'ase.bicep' = {
  scope: rg
  params: {
    name: name('ase', '01')
    location: location
    snetId: snet['snet-ase'].id
    vnetId: vnetM.outputs.id
  }
}

module aspM 'asp.bicep' = {
  scope: rg
  params: {
    name: name('asp', '01')
    kind: 'linux'
    aseId: aseM.outputs.id
    sku: {
      name: 'I1mV2'
      tier: 'IsolatedMV2'
    }
  }
}

module acrM 'acr.bicep' = {
  scope: rg
  params: {
    name: 'acr${unique}${env}01'
    location: location
    tags: tags
    dnsRg: rg.name
    snetPepId: snet['snet-pep'].id
    ipAddress: '10.10.1.71'
    ipAddressSc: '10.10.1.72'
    allowIps: [
      ip
    ]
    rbac: [
      {
        principalId: appM.outputs.?systemAssignedMIPrincipalId
        role: 'AcrPull'
      }
      {
        principalId: funcM.outputs.?systemAssignedMIPrincipalId
        role: 'AcrPull'
      }
    ]
  }
}

resource rbacAcr1 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, deployer().objectId, 'CRDIDR')
  properties: {
    principalId: deployer().objectId
    roleDefinitionId: roleDefinitions('Container Registry Data Importer and Data Reader').id
    principalType: contains(deployer().userPrincipalName, '@') ? 'User' : 'ServicePrincipal'
  }
}

module appM 'app.bicep' = {
  scope: rgApp
  params: {
    name: name('app', '01')
    kind: 'app,linux,container'
    tags: tags
    serverFarmResourceId: aspM.outputs.id
    virtualNetworkSubnetOutboundResourceId: null // snet['snet-app'].id
    publicNetworkAccess: 'Enabled'
    enableBasicAuthFtp: true
    enableBasicAuthScm: true
    managedIdentities: {
      systemAssigned: true
    }
    configAppsettings: {
      DOCKER_REGISTRY_SERVER_URL: registryUrl
      DOCKER_REGISTRY_SERVER_USERNAME: ''
      DOCKER_REGISTRY_SERVER_PASSWORD: ''
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: 'false'
      WEBSITE_VNET_ROUTE_ALL: '1'
    }
    configWeb: {
      minTlsVersion: '1.2'
      scmMinTlsVersion: '1.2'
      healthCheckPath: '/'
      vnetRouteAllEnabled: true
    }
    siteConfig: {
      alwaysOn: true
      minimumElasticInstanceCount: 1
      linuxFxVersion: 'DOCKER|mcr.microsoft.com/appsvc/staticsite:latest' // 'DOCKER|acrczrdev01.azurecr.io/appblazor:1.0.0' 
      ipSecurityRestrictions: allowFromIp
      acrUseManagedIdentityCreds: true
    }
    privateEndpoints: {
      sites: '10.10.1.68'
      // 'sites-stage': '10.10.1.69'
    }
    virtualNetworkSubnetInboundResourceId: snet['snet-pep'].id
    privateDnsZoneId: resourceId(
      subscription().subscriptionId,
      rg.name,
      'Microsoft.Network/privateDnsZones',
      'privatelink.azurewebsites.net'
    )
    rbac: []
  }
}

module funcM 'app.bicep' = {
  scope: rgApp
  params: {
    name: name('func', '01')
    kind: 'functionapp,linux,container'
    tags: tags
    serverFarmResourceId: aspM.outputs.id
    virtualNetworkSubnetOutboundResourceId: null // snet['snet-app'].id
    publicNetworkAccess: 'Enabled'
    enableBasicAuthFtp: true
    enableBasicAuthScm: true
    managedIdentities: {
      systemAssigned: true
    }
    configAppsettings: {
      DOCKER_REGISTRY_SERVER_URL: registryUrl
      DOCKER_REGISTRY_SERVER_USERNAME: ''
      DOCKER_REGISTRY_SERVER_PASSWORD: ''
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: 'false'
      WEBSITE_VNET_ROUTE_ALL: '1'
    }
    configWeb: {
      minTlsVersion: '1.2'
      scmMinTlsVersion: '1.2'
      healthCheckPath: '/'
      vnetRouteAllEnabled: true
    }
    siteConfig: {
      alwaysOn: true
      minimumElasticInstanceCount: 1
      linuxFxVersion: 'DOCKER|mcr.microsoft.com/azure-functions/dotnet-isolated:4-dotnet-isolated10.0' // 'DOCKER|acrczrdev01.azurecr.io/functionapi:1.0.0' 
      ipSecurityRestrictions: allowFromIp
      acrUseManagedIdentityCreds: true
    }
    privateEndpoints: {
      sites: '10.10.1.70'
      // 'sites-stage': '10.10.1.69'
    }
    virtualNetworkSubnetInboundResourceId: snet['snet-pep'].id
    privateDnsZoneId: resourceId(
      subscription().subscriptionId,
      rg.name,
      'Microsoft.Network/privateDnsZones',
      'privatelink.azurewebsites.net'
    )
    rbac: []
  }
}
