targetScope = 'subscription'

param config object
param dns array

var affix = toLower('${config.environment.affix}-${config.location.affix}')
var location = config.location.name
var tags = {
  Company: config.company.affix
  Environment: config.environment.name
}

resource rgdns01 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-dns-${affix}-01'
  location: location
  tags: union(tags, {
    Service: 'dns'
  })
}

module dns01 'dns.bicep' =[for dnszone in dns:{
  scope: rgdns01
  name: 'module-${dnszone.name}'
  params: {
    dnszonename: dnszone.name
    Arecords: dnszone.Arecords
    CNAMES: dnszone.CNAMES
    TXTS: dnszone.TXTS
    MXS: dnszone.MXS
    SRVS: dnszone.SRVS
  }
}]
