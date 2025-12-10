param domainName string
param Aname string
param AValue string
param TXTname string
param TXTValue string

resource dnsz 'Microsoft.Network/dnsZones@2018-05-01' existing = {
  name: domainName
}

resource A 'Microsoft.Network/dnsZones/A@2018-05-01' = if (Aname != '' || AValue != '') {
  name: Aname
  parent: dnsz
  properties: {
    TTL: 3600
    ARecords: [
      {
        ipv4Address: AValue
      }
    ]
  }
}

resource TXTT 'Microsoft.Network/dnsZones/TXT@2018-05-01' = if (!empty(TXTValue)) {
  name: TXTname
  parent: dnsz
  properties: {
    TTL: 3600
    TXTRecords: [
      {
        value: [
          TXTValue
        ]
      }
    ]
  }
}
