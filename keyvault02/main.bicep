targetScope = 'subscription'

param config object
param myIp string
param kv object
param vnet object

var affix = toLower('${config.tags.Application}-${config.tags.Environment}')
var location = config.location
var tags = config.tags
var snet = toObject(vnetE.properties.subnets, subnet => subnet.name)
var kvName = 'kv-comp-${affix}-02'
var privateDomains = [
  'privatelink.vaultcore.azure.net'
  'privatelink.blob.core.windows.net'
]
var vms = [
  {
    name: 'vmabctest01'
  }
  {
    name: 'vmabctest02'
  }
]

resource vnetE 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: 'vnet-${affix}-01'
  scope: rg
}

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${affix}-01'
  location: location
  tags: tags
}

resource rgVm 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-vmabctest01'
  location: location
  tags: tags
}

module vnetM 'vnet.bicep' = {
  scope: rg
  name: 'vnet'
  params: {
    addressPrefixes: vnet.addressPrefixes
    affix: affix
    location: location
    subnets: vnet.subnets
    privateDomains: privateDomains
  }
}

module kvM 'kv.bicep' =
  if (!empty(kv)) {
    scope: rg
    name: 'kv'
    params: {
      location: location
      name: kvName
      sku: kv.sku
      enabledForDeployment: kv.enabledForDeployment
      enabledForDiskEncryption: kv.enabledForDiskEncryption
      enabledForTemplateDeployment: kv.enabledForTemplateDeployment
      enableRbacAuthorization: kv.enableRbacAuthorization
      snetId: snet['snet-pep'].id
      allowedIps: [
        myIp
      ]
    }
  }

module id 'id.bicep' = {
  scope: rg
  name: 'user-assigned-id'
  params: {
    location: location
    name: 'id-${affix}-01'
  }
}

module rbacKv 'rbac.bicep' = {
  scope: rg
  name: 'user-assigned-id-rbac'
  params: {
    principalId: id.outputs.principalId
    roles: [
      'Key Vault Administrator'
      'Storage File Data Privileged Contributor'
    ]
  }
}

module st 'st.bicep' =
  if (true) {
    scope: rg
    name: 'st-deployment-script'
    params: {
      name: 'stdeploymentscript01'
      location: location
      snetId: snet['snet-pep'].id
      networkAcls: {
        resourceAccessRules: []
        bypass: 'AzureServices'
        virtualNetworkRules: [
          {
            id: snet['snet-st'].id
            action: 'Allow'
          }
        ]
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
    }
  }

module vmScript 'vmScript.bicep' =
  if (false) {
    scope: rg
    name: 'deployment-script-secret'
    params: {
      kvName: kvName
      location: location
      name: 'ds-secret-${affix}-01'
      vm: vms
      idName: 'id-${affix}-01'
      snetId: snet['snet-st'].id
      stName: 'stdeploymentscript01'
    }
  }

resource kvE 'Microsoft.KeyVault/vaults@2023-07-01' existing =
  if (false) {
    name: kvName
    scope: rg
  }

module vm 'vm-mini.bicep' =
  if (false) {
    scope: rgVm
    name: 'vmabctest01'
    params: {
      name: 'vmabctest01'
      location: location
      adminPassword: kvE.getSecret('vmabctest01')
      adminUsername: 'azadmin'
      osDiskSizeGB: 128
      snetId: snet['snet-mgmt'].id
      vmSize: 'Standard_B2s'
      imageReference: {
        publisher: 'microsoftwindowsdesktop'
        offer: 'windows-11'
        sku: 'win11-22h2-avd'
        version: 'latest'
      }
      networkInterfaces: [
        {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.0.1.135'
          primary: true
          publicIPAddress: true
          enableIPForwarding: false
          enableAcceleratedNetworking: false
        }
      ]
    }
  }
