targetScope = 'subscription'

param tags object
param env string
// param timestamp int = dateTimeToEpoch(utcNow())
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
param disks {
  name: string
  dataDisks: {
    name: string
    storageAccountType: (
      | 'PremiumV2_LRS'
      | 'Premium_LRS'
      | 'Premium_ZRS'
      | 'StandardSSD_LRS'
      | 'StandardSSD_ZRS'
      | 'Standard_LRS'
      | 'UltraSSD_LRS')
    diskSizeGB: int
    createOption: 'Empty' | 'FromImage' | 'Attach'
    encryption: bool
  }[]
}[]

var kvOutputs = toObject(
  kvM,
  entry => entry.outputs.kvName,
  entry =>
    ({
      kvId: entry.outputs.kvId
      kvUrl: entry.outputs.kvUrl
      keyUrl: entry.outputs.keyUrl
    })
)
var unique = take(uniqueString(subscription().subscriptionId), 3)
var prefix = toLower('${unique}-${env}')
var domains = [
  // 'privatelink.vaultcore.azure.net'
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

module disksM 'disk.bicep' = [
  for d in disks: {
    scope: rgDes
    params: {
      name: d.name
      location: location
      dataDisks: d.dataDisks
      diskEncryptionSetId: desM.outputs.desId
    }
  }
]

module desM 'des.bicep' = {
  scope: rgDes
  params: {
    name: 'desdev01'
    location: location
    keyUrl: kvOutputs.kvdesdev01.keyUrl
    keyVaultId: kvOutputs.kvdesdev01.kvId
    rbac: [
      'Key Vault Crypto Service Encryption'
    ]
  }
}

output kv1 string = string(kvOutputs.kvdesdev01.kvId)
