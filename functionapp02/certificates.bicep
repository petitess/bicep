param name string
param keyVaultId string
@description('CN=*.abc.se')
param distinguishedName string

resource certificateOrder01 'Microsoft.CertificateRegistration/certificateOrders@2024-04-01' = {
  name: name
  location: 'global'
  tags: resourceGroup().tags
  properties: {
    autoRenew: false
    distinguishedName: distinguishedName
    validityInYears: 1
    productType: 'StandardDomainValidatedWildCardSsl'
  }

  resource cert 'certificates' = {
    name: name
    location: 'global'

    properties: {
      keyVaultId: keyVaultId
      keyVaultSecretName: name
    }
  }
}

resource lock 'Microsoft.Authorization/locks@2020-05-01' = if(false) {
  name: 'dontdelete'
  scope: certificateOrder01
  properties: {
    level: 'CanNotDelete'
  }
}
