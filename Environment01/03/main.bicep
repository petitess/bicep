targetScope = 'subscription'

param config object
param virtualnetwork object

var location = config.location.name
var envloc = toLower('${config.environment.affix}-${config.location.affix}')
var subid = take(subscription().subscriptionId, 5)
var tags = {
  Company: config.company.name
  Environment: config.environment.name
}

resource RG1 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-vnet-${envloc}-01'
  location: location
  tags: union(tags, {
    Application: 'Infrastructure'
  })
  
}

module vnet 'vnet.bicep' = {
  scope: RG1 
  name: 'module-${envloc}-vnet01'
  params: {
    name: 'vnet-${envloc}-01'
    location: location
    addressPrefixes: virtualnetwork.addressPrefixes
    dnsServers: virtualnetwork.dnsServers
    subnets: virtualnetwork.subnets
  }
}

resource RG2 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-govern-${envloc}-01'
  location: location
  tags: union(tags, {
    Application : 'Governance'
})
}

module keyvault 'kv.bicep' = {
  scope: RG2
  name: 'module-${envloc}-kv01'
  params: {
    location: location
    kvname: 'kv-${subid}-${envloc}-01'
    principalId: id.outputs.id
  }
}

module id 'id.bicep' = {
  scope: RG2
  name: 'module-${envloc}-id01'
  params: {
    location: location
    name: 'id-${subid}-${envloc}-01'
  }
}

resource role01 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid('role-${subid}-${envloc}-01')
  dependsOn: [
    id
  ]
  properties: {
    principalId: id.outputs.id
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
    description: 'Contributor'
  }
resource role02 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid('role-${subid}-${envloc}-03')
  dependsOn: [
    id
  ]
  properties: {
    principalId: id.outputs.id
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '00482a5a-887f-4fb3-b363-3b7fe8e74483')
    description: 'Key Vault Admin'
  }
}
