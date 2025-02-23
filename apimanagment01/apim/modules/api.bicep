param name string
param displayName string
param apimName string
param url string
param path string
param swaggerPath string
param environment string
param roles string

resource apim 'Microsoft.ApiManagement/service@2024-06-01-preview' existing = if (environment != 'prod') {
  name: apimName
}

var commonPolicy = replace(
  replace(replace(loadTextContent('../policies/commonPolicy.xml'), '{tenantId}', tenant().tenantId), '{roles}', roles),
  '{backendName}',
  backend.name
)

resource api 'Microsoft.ApiManagement/service/apis@2024-06-01-preview' = if (environment != 'prod') {
  parent: apim
  name: name
  properties: {
    displayName: displayName
    apiRevision: '1'
    subscriptionRequired: false
    path: path
    protocols: [
      'https'
    ]
    authenticationSettings: {
      oAuth2AuthenticationSettings: []
      openidAuthenticationSettings: []
    }
    // subscriptionKeyParameterNames: {
    //   header: 'Ocp-Apim-Subscription-Key'
    //   query: 'subscription-key'

    // }
    value: '${url}${swaggerPath}'
    format: 'openapi-link'
  }
}

resource common 'Microsoft.ApiManagement/service/apis/policies@2024-06-01-preview' = {
  name: 'policy'
  parent: api
  properties: {
    value: commonPolicy
    format: 'rawxml'
  }
}

resource backend 'Microsoft.ApiManagement/service/backends@2024-06-01-preview' = if (environment != 'prod') {
  name: 'backend-${name}'
  parent: apim
  properties: {
    title: 'Karol'
    description: 'description'
    url: url
    protocol: 'http'
    credentials: {
      query: {}
      header: {}
    }
    tls: {
      validateCertificateChain: true
      validateCertificateName: true
    }
  }
}
