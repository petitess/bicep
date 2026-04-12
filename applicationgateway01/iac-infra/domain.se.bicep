param domain string
var location = 'global'
var tags = resourceGroup().tags

var Arecords = [
  {
    name: 'api'
    ipv4Address: '20.240.1.1' //awg
  }
  {
    name: 'api-dev'
    ipv4Address: '20.245.1.1' //awg
  }
]

var Cnames = [
  // {
  //   name: 'api-dev' //for domain verification
  //   cname: 'apim-dev-abcd-01.azure-api.net'
  // }
  // {
  //   name: 'api' //for domain verification
  //   cname: 'apim-prod-abcd-01.azure-api.net'
  // }
  {
    name: 'portal-api'
    cname: 'apim-prod-abcd-01.developer.azure-api.net'
  }
]

var MX = []

var SRV = []

var TXT = []

resource dnsz 'Microsoft.Network/dnsZones@2023-07-01-preview' = {
  name: domain
  location: location
  tags: tags
}

resource A 'Microsoft.Network/dnsZones/A@2023-07-01-preview' = [
  for a in Arecords: {
    name: a.name
    parent: dnsz
    properties: {
      TTL: a.?TTL ?? 3600
      ARecords: a.?ipv4Addresses ?? [
        {
          ipv4Address: a.?ipv4Address
        }
      ]
    }
  }
]

resource CNAME 'Microsoft.Network/dnsZones/CNAME@2023-07-01-preview' = [
  for c in Cnames: {
    name: c.name
    parent: dnsz
    properties: {
      TTL: c.?TTL ?? 3600
      CNAMERecord: {
        cname: c.cname
      }
    }
  }
]

resource MXX 'Microsoft.Network/dnsZones/MX@2023-07-01-preview' = [
  for m in MX: {
    name: m.name
    parent: dnsz
    properties: {
      TTL: m.?TTL ?? 3600
      MXRecords: [
        {
          exchange: m.exchange
          preference: m.preference
        }
      ]
    }
  }
]

resource SRVV 'Microsoft.Network/dnsZones/SRV@2023-07-01-preview' = [
  for s in SRV: {
    name: s.name
    parent: dnsz
    properties: {
      TTL: s.?TTL ?? 3600
      SRVRecords: [
        {
          port: s.port
          priority: s.priority
          target: s.target
          weight: s.weight
        }
      ]
    }
  }
]

resource TXTT 'Microsoft.Network/dnsZones/TXT@2023-07-01-preview' = [
  for t in TXT: {
    name: t.name
    parent: dnsz
    properties: {
      TTL: t.?TTL ?? 3600
      TXTRecords: t.TXTRecords
    }
  }
]
