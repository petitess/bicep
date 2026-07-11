param name string
param location string
param federatedIdentityCredentials {
  name: string
  subject: string
  issuer: string?
}[]?

resource idR 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-05-31-preview' = {
  name: name
  location: location
  properties: {}
}

resource fed 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2025-05-31-preview' = [
  for i in federatedIdentityCredentials ?? []: {
    name: i.name
    parent: idR
    properties: {
      audiences: ['api://AzureADTokenExchange']
      subject: i.subject
      issuer: i.?issuer ?? '${environment().authentication.loginEndpoint}/${tenant().tenantId}/v2.0'
    }
  }
]

output name string = idR.name
