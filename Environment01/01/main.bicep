targetScope = 'subscription'

param config object
param virtualnetwork object

var location = config.location.name
var envloc = toLower('${config.environment.affix}-${config.location.affix}')
var tags = {
  Company: config.company.name
  Environment: config.environment.name
}

resource RG1 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-vnet-${envloc}-01'
  tags: union(tags, {
    Application: 'Infrastructure'
  })
  location: location
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


