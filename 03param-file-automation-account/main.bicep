/*
This is a simple deployment, using a parameter file.
If you want to connect to a VM, add RDP to NSG and remove Route Table from Subnet
If you want to see key vault secrets make your user a Key Vault Administrator
- One VNET with Subnets connected to NSGs.
- Route tables
- 3 VMs with Public IP adress(if set to "true")
- A key vault containing secrets as windows login
- A managed identity to run a powershell script to deploy key vault secrets
- An automation account with managed identity with scheduled powershell script
*/
targetScope =  'subscription'


param config object
param virtualMachines array
param virtualNetwork object
param managedidentity_rbac object


var location = config.location.name
var locationAlt = config.location.alt.name
var tags = {
  Company: config.company.name
  Environment: config.environment.name
}

var affix = {
  environment: toLower('${config.environment.affix}')
  environmentLocation: toLower('${config.environment.affix}-${config.location.affix}')
  environmentLocationAlt: toLower('${config.environment.affix}-${config.location.alt.affix}')
  environmentCompany: toLower('${config.environment.affix}-${config.company.affix}')
  environmentCompanyStripped: toLower('${config.environment.affix}${config.company.affix}')
}

resource rgInfra 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: toLower('rg-infra-${affix.environmentLocation}-01')
  location: location
  tags: union(tags, {
    Application: 'Infrastructure'
  })
}

//
resource SUBrole 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' =  {
  name: guid('contributor_sub', subscription().id)
  properties: {
    principalId: Id.outputs.principalID
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', managedidentity_rbac.Contributor.value)
  }
}


resource rgVm 'Microsoft.Resources/resourceGroups@2021-04-01' = [for virtualMachine in virtualMachines: {
  name: toLower('rg-${virtualMachine.name}')
  location: location
  tags: union(tags, {
    Application: virtualMachine.tags.Application
  })
}]

module Vnet 'vnet.bicep' = {
  scope: rgInfra
  name: 'module-${affix.environment}-vnet'
  params: {
    addressPrefixes: virtualNetwork.addressPrefixes
    dnsServers: virtualNetwork.dnsServers
    location: rgInfra.location
    name: 'vnet-${affix.environmentLocation}-01'
    natGateway: virtualNetwork.natGateway
    subnets: virtualNetwork.subnets
  }
}

resource kvExisting 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  scope: resourceGroup(rgKV.name)
  name: toLower('kv-infra-${affix.environmentCompany}-01')
}

module vm 'vm.bicep' = [for (virtualMachine, i) in virtualMachines: {
  name: 'module-${affix.environment}-${virtualMachine.name}'
  scope: rgVm[i]
  params: {
    location: location
    adminPassword: kvExisting.getSecret(virtualMachine.name)
    adminUsername: kvExisting.getSecret(scripts.outputs.adminUsername)
    offer: virtualMachine.imageReference.offer
    publisher: virtualMachine.imageReference.publisher
    vmSize: virtualMachine.vmSize
    skus: virtualMachine.imageReference.sku
    networkInterfaces: virtualMachine.networkInterfaces
    name: virtualMachine.name
    tags: virtualMachine.tags
    vnetId: Vnet.outputs.vnetId
  }
}]

resource rgKV 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: toLower('rg-kv-${affix.environmentLocation}-01')
  location: location
  tags: union(tags, {
    Application: 'Governance'

  })
}

module Id 'id.bicep' = {
  scope: rgKV
  name: 'module-${affix.environment}-id01'
  params: {
    name: toLower('id-script-${affix.environmentLocation}-01')
    location: location
    roleDefinitionId01: managedidentity_rbac.Contributor.value
    roleDefinitionId02: managedidentity_rbac.Key_Vault_Administrator.value
    roleDefinitionId03: managedidentity_rbac.User_Access_Administrator.value
    kvname: toLower('kv-infra-${affix.environmentCompany}-01')
  }
}

module kv 'kv.bicep' = {
  scope: rgKV
  name: 'module-${affix.environment}-kv'
  params: {
    location: rgInfra.location
    name: 'kv-infra-${affix.environmentCompany}-01' //must be globally unique 
  }
}

module scripts 'scripts.bicep' = {
  scope: rgKV
  name: 'module-${affix.environment}-scripts'
  params: {
    affix: affix
    kvName: kv.outputs.kvName
    location: locationAlt //swedencentral not supported
    virtualMachines: virtualMachines

  }
}

resource AA 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: toLower('rg-aa-${affix.environmentLocation}-01')
  location: location
  tags: union(tags, {

  })
}

module automationa 'aa.bicep' = {
  scope: AA
  name: 'module-${affix.environment}-automation'
  params: {
    location: AA.location
    name: 'aa-infra-${affix.environmentCompany}-01'
    roleDefinitionId01: managedidentity_rbac.Contributor.value
    roleDefinitionId03: managedidentity_rbac.User_Access_Administrator.value
    idname: 'id-script-${affix.environmentLocation}-01'
    idscope: rgKV.name
  }
}





