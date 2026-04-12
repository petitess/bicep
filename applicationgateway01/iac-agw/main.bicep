targetScope = 'subscription'

param env string
param tags object
param timestamp int = dateTimeToEpoch(utcNow())
param location string = deployment().location
param agw {
  name: string
  privateip: string
  sslCertificates: ('SecretName' | 'CertName')[]
  sites: {
    hostname: string
    public: bool
    pickHostNameFromBackendAddress: bool
    protocol: 'https'
    port: '443'
    priority: int
    backendAddresses: [
      {
        fqdn: string
      }
    ]
    probePath: string
    probeHost: string
    probeStatus: string[]
    waf: object
  }[]
}

var prefix = toLower('sys-${env}')

func name(res string, instance string) string => '${res}-${prefix}-${instance}'

resource kvExisting 'Microsoft.KeyVault/vaults@2025-05-01' existing = {
  scope: resourceGroup(name('rg-vnet', '01'))
  name: toLower('kvcertabc${env}01')
}

resource rgAgw 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: name('rg-agw', '01')
  location: location
  tags: tags
}

module AGW 'agw.bicep' = {
  scope: rgAgw
  name: 'agw-${env}-01'
  params: {
    agw: agw
    location: location
    sites: agw.sites
    env: env
    rgVnetName: 'rg-vnet-sys-${env}-01'
    vnetName: 'vnet-sys-${env}-01'
    snetName: 'snet-agw'
    pass: ''
    certdata: kvExisting.getSecret(agw.sslCertificates[0])
  }
}
