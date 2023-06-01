resource certificateOrder01 'Microsoft.CertificateRegistration/certificateOrders@2022-09-01' = {
  name: 'cert-wildcard-business-se'
  location: 'global'
  tags: resourceGroup().tags
  properties: {
    autoRenew: true
    distinguishedName: 'CN=*.business.se'
    validityInYears: 1
    productType: 'StandardDomainValidatedWildCardSsl'
  }
}

resource lock01 'Microsoft.Authorization/locks@2020-05-01' = {
  name: 'dontdelete'
  scope: certificateOrder01
  properties: {
    level: 'CanNotDelete'
  }
}

resource certificateOrder02 'Microsoft.CertificateRegistration/certificateOrders@2022-09-01' = {
  name: 'cert-wildcard-company-se'
  location: 'global'
  tags: resourceGroup().tags
  properties: {
    autoRenew: true
    distinguishedName: 'CN=company.se'
    validityInYears: 1
    productType: 'StandardDomainValidatedSsl'
  }
}

resource lock02 'Microsoft.Authorization/locks@2020-05-01' = {
  name: 'dontdelete'
  scope: certificateOrder02
  properties: {
    level: 'CanNotDelete'
  }
}
