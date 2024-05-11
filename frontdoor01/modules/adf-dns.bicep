param name string
param deployCNAME bool
param Cname string
param CnameValue string
param TXTname string
param TXTValue string

resource dnsz 'Microsoft.Network/dnsZones@2023-07-01-preview' existing = {
  name: name
}

resource CNAME 'Microsoft.Network/dnsZones/CNAME@2023-07-01-preview' = if (deployCNAME) {
  name: Cname
  parent: dnsz
  properties: {
    TTL: 3600
    CNAMERecord: {
      cname: CnameValue
    }
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
