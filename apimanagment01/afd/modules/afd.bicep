param name string
param tags object = resourceGroup().tags
param logId string
param sslCertificates array
param prefixCert string
param prefixSpoke string

resource kv 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: 'kv-${prefixCert}-01'
  scope: resourceGroup('rg-${prefixSpoke}-01')

  resource secret 'secrets' existing = [
    for sslCertificate in sslCertificates: {
      name: sslCertificate
    }
  ]
}

resource id 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'id-${name}'
  location: resourceGroup().location
  tags: tags
}

resource afd 'Microsoft.Cdn/profiles@2024-02-01' = {
  name: name
  location: 'Global'
  tags: tags
  sku: {
    name: 'Premium_AzureFrontDoor'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${id.id}': {}
    }
  }
  properties: {
    originResponseTimeoutSeconds: 60
  }
}

resource afdSecrets 'Microsoft.Cdn/profiles/secrets@2024-09-01' = [
  for (sslCertificate, i) in sslCertificates: {
    name: sslCertificate
    parent: afd
    properties: {
      parameters: {
        type: 'CustomerCertificate'
        secretSource: {
          id: kv::secret[i].id
        }
        useLatestVersion: true
      }
    }
  }
]

resource diag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${name}'
  scope: afd
  properties: {
    workspaceId: logId
    logs: [
      {
        enabled: true
        category: 'FrontDoorAccessLog'
      }
      {
        enabled: true
        category: 'FrontDoorHealthProbeLog'
      }
      {
        enabled: true
        category: 'FrontDoorWebApplicationFirewallLog'
      }
    ]
  }
}
