targetScope = 'resourceGroup'

param dnszonename string
param Arecords array
param CNAMES array
param TXTS array
param MXS array
param SRVS array

var tags = resourceGroup().tags

resource dns 'Microsoft.Network/dnsZones@2023-07-01-preview' = {
  name: dnszonename
  location: 'global'
  tags: tags
  properties: {
    zoneType: 'Public'
  }
}

resource dnsA 'Microsoft.Network/dnsZones/A@2023-07-01-preview' = [for Arecord in Arecords:  {
  name: Arecord.name
  parent:dns
  properties: {
    TTL: Arecord.properites.TLL
    ARecords: Arecord.properites.Arecords
  }
}]

resource dnsCN 'Microsoft.Network/dnsZones/CNAME@2023-07-01-preview' = [for CNAME in CNAMES: {
  name: CNAME.name
  parent: dns
  properties: {
    TTL: CNAME.properties.TLL
    CNAMERecord: CNAME.properties.CNAMERecord
  }
}]

resource dnsTXT 'Microsoft.Network/dnsZones/TXT@2023-07-01-preview' =[for TXT in TXTS: {
  name: TXT.name
  parent: dns
  properties: {
    TTL: TXT.properties.TLL
    TXTRecords: TXT.properties.TXTRecords
  }
}]

resource dnsMX 'Microsoft.Network/dnsZones/MX@2023-07-01-preview' = [for MX in MXS: {
  name: MX.name
  parent: dns
  properties: {
    TTL: MX.properties.TLL
    MXRecords: MX.properties.MXRecords 
  }
}]

resource dnsSRV 'Microsoft.Network/dnsZones/SRV@2023-07-01-preview' = [for SRV in SRVS: {
  name: SRV.name
  parent: dns
  properties: {
    TTL: SRV.properties.TTL
    SRVRecords: SRV.properties.SRVRecords
  }
}]
