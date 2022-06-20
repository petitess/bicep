targetScope = 'subscription'

param config object
param dnszone01 object

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

module dns01 'dns.bicep' = {
  scope: rgdns01
  name: 'module'
  params: {
    dnszonename: dnszone01.name
    Arecords: dnszone01.Arecords
    CNAMES: dnszone01.CNAMES
    TXTS: dnszone01.TXTS
    MXS: dnszone01.MXS
  }
}
