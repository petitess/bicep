targetScope = 'subscription'

param config object
param environment string
param location string = deployment().location
param vnet object

var prefix = toLower('${config.product}-${environment}-${config.location}')
var prefixSt = toLower('${config.product}${environment}${config.location}')
var subnet = toObject(
  reference(
    resourceId(subscription().subscriptionId, rg.name, 'Microsoft.Network/virtualNetworks', 'vnet-${prefix}-01'),
    '2023-11-01'
  ).subnets,
  subnet => subnet.name
)
var myIp = '188.150.1.1'

var domains = [
  'privatelink.blob.${az.environment().suffixes.storage}'
  'privatelink.file.${az.environment().suffixes.storage}'
]

var disks = [
  {
    name: 'disk'
    backup: true
  }
]

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-hub-${prefix}-01'
  location: location
  tags: union(config.tags, {
    System: config.product
  })
}

resource rgSt 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-st-${prefix}-01'
  location: location
  tags: union(config.tags, {
    System: config.product
  })
}

resource rgBVault 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-bvault-${prefix}-01'
  location: location
  tags: union(config.tags, {
    System: config.product
  })
}

resource rgDisk 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-disk-${prefix}-01'
  location: location
  tags: union(config.tags, {
    System: config.product
  })
}

module vnetM 'modules/vnet.bicep' = {
  name: 'vnet'
  scope: rg
  params: {
    prefix: prefix
    location: location
    addressPrefixes: vnet.addressPrefixes
    subnets: vnet.subnets
    flowLogsEnabled: false
  }
}

module pdnszM 'modules/pdnsz.bicep' = [
  for (domain, i) in domains: {
    name: 'pdnsz_${split(domain, '.')[1]}'
    scope: rg
    params: {
      name: domain
      vnetName: vnetM.outputs.name
      vnetId: vnetM.outputs.id
    }
  }
]

module stM 'modules/st.bicep' = {
  scope: rgSt
  name: 'st'
  params: {
    name: 'stfunc${prefixSt}01'
    location: location
    dnsRgName: rg.name
    snetId: subnet['snet-pep'].id
    vaultName: 'bvault-${prefix}-01'
    vaultRgName: rgBVault.name
    blobBackupPolicyId: bvaultM.outputs.policy_vaulted_blob
    networkAcls: {
      resourceAccessRules: []
      bypass: 'AzureServices'
      ipRules: [
        {
          value: myIp
        }
      ]
      defaultAction: 'deny'
    }
    privateEndpoints: [
      'blob'
    ]
    containers: [
      {
        name: 'container01'
        immutability: false
        backup: false
      }
      {
        name: 'container02'
        immutability: false
        backup: true
      }
    ]
  }
}

module bvaultM 'modules/bvault.bicep' = {
  scope: rgBVault
  name: 'bvault'
  params: {
    name: 'bvault-${prefix}-01'
    redundancy: 'GeoRedundant'
  }
}

module rbacBackupBlob 'modules/rbac.bicep' = {
  scope: rgSt
  name: 'rbac-backup-blob'
  params: {
    principalId: bvaultM.outputs.principalId
    roles: [
      'Storage Account Backup Contributor'
    ]
  }
}

module disksM 'modules/disk.bicep' = [
  for (d, i) in disks: {
    scope: rgDisk
    name: 'disk_${i+1}'
    params: {
      name: '${d.name}-${prefix}-0${i+1}'
      vaultName: 'bvault-${prefix}-01'
      vaultRgName: rgBVault.name
      backup: d.backup
      policyId: bvaultM.outputs.policy_disk
    }
  }
]

module rbacBackupDisk 'modules/rbac.bicep' = {
  scope: rgDisk
  name: 'rbac-backup-disk'
  params: {
    principalId: bvaultM.outputs.principalId
    roles: [
      'Disk Backup Reader'
    ]
  }
}
