targetScope = 'subscription'

param tags object
param env string
// param timestamp int = dateTimeToEpoch(utcNow())
param location string = deployment().location
param vnet object
param serviceBus {
  name: string
  resourcegroup: string
  sku: ('Basic' | 'Standard' | 'Premium')
  subscriptions_topics: { *: string }?
  ipAddress: string
  queues: string[]
  allowIPs: string[]
  rbac: {
    role: ('Azure Service Bus Data Owner' | 'Contributor')
    principalId: string
    principalType: ('Device' | 'ForeignGroup' | 'Group' | 'ServicePrincipal' | 'User')?
  }[]?
}[]

var unique = take(uniqueString(subscription().subscriptionId), 3)
var prefix = toLower('${unique}-${env}')
var domains = [
  'privatelink.servicebus.windows.net'
]
func name(res string, instance string) string => '${res}-${prefix}-${instance}'

resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: name('rg-vnet', '01')
  location: location
  tags: tags
}

resource rgSb 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: 'rg-integration-${env}-01'
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

module sb 'sb.bicep' = [
  for sb in serviceBus: {
    scope: resourceGroup(sb.resourcegroup)
    params: {
      location: location
      name: sb.name
      sku: sb.sku
      subscriptions_topics: sb.?subscriptions_topics ?? {}
      rbac: sb.?rbac
      dnsRg: rg.name
      queues: sb.queues
      ipAddress: sb.ipAddress
      allowIPs: sb.allowIPs
      snetPepId: resourceId(
        subscription().subscriptionId,
        rg.name,
        'Microsoft.Network/virtualNetworks/subnets',
        vnetM.outputs.name,
        'snet-pep'
      )
    }
  }
]
