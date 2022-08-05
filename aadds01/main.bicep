targetScope = 'subscription'

param param object
var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var environment = toLower(param.tags.Environment)

resource rgvnet01 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: param.locationAlt
  tags: param.tags
  name: 'rg-${affix}-01'
}

module vnet01 'vnet.bicep' = {
  scope: rgvnet01
  name: 'module-${affix}-vnet01'
  params: {
    addressPrefixes: param.vnet01.addressPrefixes
    dnsServers: param.vnet01.dnsServers
    location: param.locationAlt
    name: 'vnet-${affix}-01'
    natGateway: param.vnet01.natGateway
    peerings: param.vnet01.peerings
    subnets: param.vnet01.subnets 
  }
}

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-aadds-${environment}-01'
  location: param.locationAlt
}

module aadds  'aadds.bicep' = {
  scope: rg
  name: 'module-aadds-01'
  params: {
    subnetId: vnet01.outputs.AADDSubId
    location: param.locationAlt
    name: 'aadds-${affix}-01'
    domainName: param.aadds.domainname
    sku: param.aadds.sku
    notificationSettings: param.aadds.notificationSettings
  }
}

output a string = '${subscription().id}/resourceGroups/${rgvnet01.name}/providers/Microsoft.Network/virtualNetworks/${vnet01.outputs.name}/subnets/snet-aadds-test-01'
output b string = vnet01.outputs.AADDSubId
output c string = '${vnet01.outputs.id}/subnets/snet-aadds-test-01'
output d string = '${vnet01.outputs.id}/subnets/${vnet01.outputs.AADDSubName}'


