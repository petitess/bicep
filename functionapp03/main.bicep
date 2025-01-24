targetScope = 'subscription'

extension 'br:mcr.microsoft.com/bicep/extensions/microsoftgraph/v1.0:0.1.8-preview'

param env string
param location string
param tags object
param vnet object
param timestamp int = dateTimeToEpoch(utcNow())
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

param funcApps ({
  name: string
  resourceGroup: string
  kind: 'functionapp,linux' | 'functionapp'
  aspName: string?
  appSettings: ({ name: string, value: string })[]?
  slot: ({
    name: ('stage')?
    appSettings: ({ name: string, value: string })[]
    customDomain: string?
    authEnabled: bool?
  }?)
  privateEndpoints: ({ sites: string?, 'sites-stage': string? })
  customDomain: string?
  rbac: ({
    role: ('Website Contributor' | 'Reader' | 'Contributor' | 'Storage Blob Data Contributor')
    principalId: string
  })[]?
  authEnabled: bool
  auth: ({ authClientId: string, authAllowedAudience: string })?
  isFlexConsumptionTier: bool
  storageName: string?
  storageContainerName: string?
})[]

param myIP string
@description('az ad sp list  --display-name "microsoft.azure.certificateregistration"')
param appCertificateRegistration string = '5ac1ac3c-9e22-439b-acfb-6694f6522409'
@description('az ad sp show --id "abfa0a7c-a6b6-4736-8310-5855508787cd"')
param appMicrosoftAzureAppService string = '2d0abffa-b360-4f2f-9478-951498a43bd8'
var domains = [
  'privatelink.blob.${environment().suffixes.storage}'
  'privatelink.file.${environment().suffixes.storage}'
  'privatelink.azurewebsites.net'
  'privatelink.vaultcore.azure.net'
  'privatelink.eventgrid.azure.net'
]

var auth = {
  authAllowedAudience: appReg.identifierUris[0]
  authClientId: appReg.appId
}

var functionDeployed = true
var affix = toLower('${tags.Application}-${env}')
func name(prefix string, instance string) string => '${prefix}-${affix}-${instance}'
func aspId(aspName string?, rgName string) string =>
  resourceId(subscription().subscriptionId, rgName, 'Microsoft.Web/serverfarms', aspName)

var snet = toObject(vnetE.properties.subnets, subnet => subnet.name)

resource vnetE 'Microsoft.Network/virtualNetworks@2024-03-01' existing = {
  name: name('vnet', '01')
  scope: resourceGroup(name('rg-vnet', '01'))
  dependsOn: [
    vnetM
    rg
  ]
}

resource rg 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  location: location
  tags: tags
  name: name('rg-vnet', '01')
}

resource rgDns 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  location: location
  tags: tags
  name: name('rg-dns', '01')
}

resource rgAsp 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  location: location
  tags: tags
  name: name('rg-asp', '01')
}

module vnetM 'vnet.bicep' = {
  scope: rg
  name: 'vnet-${timestamp}'
  params: {
    addressPrefixes: vnet.addressPrefixes
    name: name('vnet', '01')
    location: location
    subnets: vnet.subnets
  }
}

module st 'st.bicep' = [
  for (st, i) in storageAccounts: {
    name: '${st.name}-${timestamp}'
    scope: resourceGroup(st.resourceGroup)
    dependsOn: [
      resourceGroup(rgFunc[i].name)
    ]
    params: {
      name: st.name
      location: location
      skuName: st.skuName
      isSftpEnabled: st.isSftpEnabled
      publicAccess: st.publicAccess
      allowedIPs: st.allowedIPs
      snetPepId: snet['snet-pep'].id
      privateEndpoints: items(st.privateEndpoints)
      privateDnsZoneRg: rgDns.name
      shares: st.shares
      containers: st.containers
      rbac: st.?rbac ?? []
    }
  }
]

module pdnszM 'pdnsz.bicep' = [
  for (domain, i) in domains: {
    name: 'pdnsz-${split(domain, '.')[1]}'
    scope: rgDns
    params: {
      name: domain
      vnetName: vnetM.outputs.name
      vnetId: vnetM.outputs.id
    }
  }
]

module kv 'kv.bicep' = if(false) {
  scope: rg
  name: 'kv'
  params: {
    name: 'kv-cert-abc-${env}-01'
    location: location
    tags: tags
    snetPepId: snet['snet-pep'].id
    ipAddress: cidrSubnet(snet['snet-pep'].properties.addressPrefix, 32, 8)
    allowIPs: [
      myIP
    ]
    privateDnsZoneId: resourceId(
      subscription().subscriptionId,
      rgDns.name,
      'Microsoft.Network/privateDnsZones',
      'privatelink.vaultcore.azure.net'
    )
    rbac: [
      {
        principalId: appCertificateRegistration
        role: 'Key Vault Secrets Officer'
      }
      {
        principalId: appMicrosoftAzureAppService
        role: 'Key Vault Secrets Officer'
      }
    ]
  }
}

module cert 'certificates.bicep' = if(false) {
  scope: rg
  name: 'cert'
  params: {
    name: 'cert-wildcard-domainabc-se'
    distinguishedName: 'CN=*.domainabc.se'
    keyVaultId: kv.outputs.id
  }
}

module aspLinuxM 'asp.bicep' = if (false) {
  scope: rgAsp
  name: 'asp-linux'
  params: {
    kind: 'linux'
    name: name('asp', '01')
    sku: 'FC1'
    //keyVaultId: kv.outputs.id
    //keyVaultSecretName: ''
  }
}

resource rgFunc 'Microsoft.Resources/resourceGroups@2024-07-01' = [
  for rg in union(map(funcApps, rg => rg.resourceGroup), map(funcApps, rg => rg.resourceGroup)): {
    name: toLower(rg)
    location: location
    tags: tags
  }
]

module aspFuncFlex 'asp.bicep' = [
  for f in funcApps: if (f.isFlexConsumptionTier) {
    scope: resourceGroup(f.resourceGroup)
    name: 'asp-${f.name}'
    params: {
      kind: 'linux'
      name: 'asp-${f.name}'
      sku: 'FC1'
    }
  }
]

module funcLinux 'func.bicep' = [
  for (f, i) in funcApps: {
    scope: resourceGroup(f.resourceGroup)
    name: f.name
    dependsOn: f.isFlexConsumptionTier
      ? [aspFuncFlex[i]]
      : [
          aspLinuxM
        ]
    params: {
      funcAppServicePlanId: f.isFlexConsumptionTier
        ? aspId('asp-${f.name}', f.resourceGroup)
        : aspId(f.aspName, name('asp', '01'))
      name: f.name
      kind: f.kind
      snetOutboundId: f.isFlexConsumptionTier ? snet['snet-app-flex'].id : snet['snet-app'].id
      defaultEndpointsProtocol: st[0].outputs.defaultEndpointsProtocol
      snetPepId: snet['snet-pep'].id
      privateDnsZoneId: resourceId(
        subscription().subscriptionId,
        rgDns.name,
        'Microsoft.Network/privateDnsZones',
        'privatelink.azurewebsites.net'
      )
      privateEndpoints: f.privateEndpoints
      appSettings: f.?appSettings ?? []
      slot: f.?slot ?? {}
      customDomain: f.?customDomain ?? ''
      rbac: f.?rbac ?? []
      auth: f.authEnabled ? auth : {}
      isFlexConsumptionTier: f.isFlexConsumptionTier
      storageName: f.?storageName ?? ''
      storageContainerName: f.?storageContainerName ?? ''
      appiConnectionString: 'InstrumentationKey=7e6976d6-1fd7-43ba-8e60-9ce7acb37f7c;IngestionEndpoint=https://swedencentral-0.in.applicationinsights.azure.com/;ApplicationId=1837fd6c-bca5-45e0-9302-979943955166'
    }
  }
]

module evgtM 'evgt.bicep' = {
  scope: rgFunc[0]
  name: 'evgt-${timestamp}'
  params: {
    name: name('evgt', '01')
    location: location
    tags: tags
    ipAddress: cidrSubnet(snet['snet-pep'].properties.addressPrefix, 32, 10)
    snetPepId: snet['snet-pep'].id
    functionId: functionDeployed ? resourceId(subscription().subscriptionId, rgFunc[0].name, 'Microsoft.Web/sites/functions', 'func-eventgrid-${env}-01', 'Create_Blobs') : ''
    privateDnsZoneId: resourceId(
      subscription().subscriptionId,
      rgDns.name,
      'Microsoft.Network/privateDnsZones',
      'privatelink.eventgrid.azure.net'
    )
  }
}

resource appReg 'Microsoft.Graph/applications@v1.0' = if (false) {
  displayName: 'app-func-${env}-01'
  uniqueName: 'app-func-${env}-01'
  description: 'Updated: ${dateTimeFromEpoch(timestamp)}'
  identifierUris: [
    'api://func-${env}-01'
  ]
}
