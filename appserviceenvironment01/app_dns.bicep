param domainName string
param Aname string
param AValue string
param TXTname string
param TXTValue string

resource dnsz 'Microsoft.Network/dnsZones@2023-07-01-preview' existing = {
  name: domainName
}

resource A 'Microsoft.Network/dnsZones/A@2023-07-01-preview' = if (Aname != '' || AValue != '') {
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

resource TXTT 'Microsoft.Network/dnsZones/TXT@2023-07-01-preview' = if (!empty(TXTValue)) {
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
