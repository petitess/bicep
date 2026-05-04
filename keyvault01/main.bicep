targetScope = 'subscription'

param tags object
param env string
param location string = deployment().location
param vnet object
param keyVaults {
  name: string
  rgName: string
  publicNetworkAccess: 'Allow' | 'Deny'
  allowIps: string[]
  ipAddress: string
  enablePurgeProtection: bool
}[]
param keys { name: string, encryption: 'KeyRSA3072' | 'KeyRSA4096' }[] = [
  {
    name: 'key1'
    encryption: 'KeyRSA3072'
  }
  {
    name: 'key2'
    encryption: 'KeyRSA4096'
  }
]
param vms {
  name: string
  rgName: string
  availabilitySetName: string
  tags: object
  vmSize: string
  plan: {
    name: string?
    product: string?
    publisher: string?
  }
  imageReference: {
    publisher: string
    offer: string
    sku: string
    version: string
  }
  osDiskSizeGB: int
  dataDisks: {
    name: string
    storageAccountType: 'PremiumV2_LRS' | 'Premium_LRS' | 'Premium_ZRS' | 'StandardSSD_LRS' | 'StandardSSD_ZRS' | 'Standard_LRS' | 'UltraSSD_LRS'
    createOption: 'Attach' | 'Copy' | 'Empty' | 'FromImage' | 'Restore'
    lun: int
    diskSizeGB: int
  }[]
  networkInterfaces: {
    privateIPAllocationMethod: 'Static'
    privateIPAddress: string
    primary: bool
    subnet: 'snet-mgmt'
    publicIPAddress: bool
    enableIPForwarding: bool
    enableAcceleratedNetworking: bool
  }[]
  backup: {
    enabled: bool
    rsvPolicyName: 'policy-vm7days01'
  }
  AzureMonitorAgentWin: bool
}[]

var kvOutputs = toObject(
  kvM,
  entry => entry.outputs.kvName,
  entry =>
    ({
      kvName: entry.outputs.kvName
      kvId: entry.outputs.kvId
      kvUrl: entry.outputs.kvUrl
      key3Url: entry.outputs.key3Url
      key4Url: entry.outputs.key4Url
    })
)
var unique = take(uniqueString(subscription().subscriptionId), 3)
var prefix = toLower('${unique}-${env}')
var domains = [
  // 'privatelink.vaultcore.azure.net'
  // 'privatelink.swedencentral.prometheus.monitor.azure.com'
]
func name(res string, instance string) string => '${res}-${prefix}-${instance}'

resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: name('rg-vnet', '01')
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

resource rgDes 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: 'rg-des-${env}-01'
  location: location
  tags: tags
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

module kvM 'kv.bicep' = [
  for kv in keyVaults: {
    scope: resourceGroup(kv.rgName)
    params: {
      name: kv.name
      location: location
      allowIps: kv.allowIps
      publicNetworkAccess: kv.publicNetworkAccess
      dnsRg: rg.name
      ipAddress: kv.ipAddress
      enablePurgeProtection: kv.enablePurgeProtection
      snetEndpoint: resourceId(
        subscription().subscriptionId,
        rg.name,
        'Microsoft.Network/virtualNetworks/subnets',
        vnetM.outputs.name,
        'snet-pep'
      )
    }
  }
]

resource rgMonitor 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: 'rg-monitor-${env}-01'
  location: location
  tags: union(tags, {
    System: 'Monitor'
  })
}

module log 'log.bicep' = {
  scope: rgMonitor
  name: 'log'
  params: {
    name: 'log-${env}-01'
    location: location
  }
}

module data 'data.bicep' = {
  scope: rgMonitor
  name: 'data'
  params: {
    location: location
    prefix: env
    workspaceResourceId: resourceId(
      subscription().subscriptionId,
      rgMonitor.name,
      'Microsoft.OperationalInsights/workspaces',
      'log-${env}-01'
    )
    workspaceName: 'log-${env}-01'
    dnsRg: rg.name
    snetId: resourceId(
      subscription().subscriptionId,
      rg.name,
      'Microsoft.Network/virtualNetworks/subnets',
      vnetM.outputs.name,
      'snet-pep'
    )
  }
}

module desM 'des.bicep' = {
  scope: rgDes
  params: {
    name: 'desdev01'
    location: location
    keyUrl: kvOutputs.kvdesdev01.key3Url
    keyVaultId: kvOutputs.kvdesdev01.kvId
    rbac: [
      'Key Vault Crypto Service Encryption'
    ]
  }
}

module key 'key.bicep' = [
  for k in keys: {
    scope: rg
    params: {
      key: reference(
        resourceId(
          subscription().subscriptionId,
          rgDes.name,
          'Microsoft.KeyVault/vaults/keys',
          'kvdes${env}01',
          k.encryption
        ),
        '2025-05-01',
        'Full'
      ).properties.keyUriWithVersion
    }
  }
]

resource rgVm 'Microsoft.Resources/resourceGroups@2024-11-01' = [
  for vm in filter(vms, v => empty(v.availabilitySetName)): {
    name: toLower('rg-${vm.name}')
    location: location
    tags: tags
  }
]

module vm 'vm.bicep' = [
  for (vm, i) in vms: {
    scope: resourceGroup(vm.rgName)
    name: vm.name
    params: {
      adminPassword: '12345678.abc'
      adminUsername: 'azadmin'
      dataDisks: vm.dataDisks
      imageReference: vm.imageReference
      location: location
      name: vm.name
      networkInterfaces: vm.networkInterfaces
      osDiskSizeGB: vm.osDiskSizeGB
      plan: vm.plan
      tags: union(tags, vm.tags)
      vmSize: vm.vmSize
      snetId: resourceId(
        subscription().subscriptionId,
        rg.name,
        'Microsoft.Network/virtualNetworks/subnets',
        vnetM.outputs.name,
        'snet-mgmt'
      )
      AzureMonitorAgentWin: vm.?AzureMonitorAgentWin ?? false
      AzureMonitorAgentLinux: vm.?AzureMonitorAgentLinux ?? false
      DataLinuxId: data.outputs.DataLinuxId
      DataWinId: data.outputs.DataWinId
      availabilitySetName: vm.availabilitySetName
      dataEndpointId: data.outputs.dataEndpointId
      dataChangeTracking: data.outputs.DataChangeTrackingId
      dataOpenTelemetry: data.outputs.DataRuleOpenTelemetryId
      diskEncryptionSetId: desM.outputs.desId
    }
  }
]

output kv1 string = string(kvOutputs.kvdesdev01.kvId)
