param name string
param displayName string
param apimName string
param description string = ''
param path string
param roles string = ''
param subscriptionRequired bool
param isCurrent bool
param serviceUrl string = ''
param policyContent string = ''
param operations array = []
param swaggerPath string = ''
@sys.description('For Developer portal')
param addProduct bool = false
@sys.description('For Developer portal')
param productState string = 'published'
@sys.description('For Developer portal')
param productVisiableForGuests bool = false
@sys.description('For Developer portal')
param addGroup bool = false
param contact object = {
  name: ''
  email: ''
}

var commonPolicy = replace(
  replace(replace(loadTextContent('../policies/commonPolicy.xml'), '{tenantId}', tenant().tenantId), '{roles}', roles),
  '{backendName}',
  backend.name
)

resource apim 'Microsoft.ApiManagement/service@2025-03-01-preview' existing = {
  name: apimName
}

resource apis 'Microsoft.ApiManagement/service/apis@2025-03-01-preview' = {
  parent: apim
  name: name
  properties: {
    displayName: displayName
    description: description
    apiRevision: '1'
    subscriptionRequired: subscriptionRequired
    path: path
    serviceUrl: serviceUrl
    isCurrent: isCurrent
    protocols: [
      'https'
    ]
    authenticationSettings: {
      oAuth2AuthenticationSettings: []
      openidAuthenticationSettings: []
    }
    subscriptionKeyParameterNames: {
      header: 'Ocp-Apim-Subscription-Key'
      query: 'subscription-key'
    }
    value: swaggerPath != '' ? '${serviceUrl}${swaggerPath}' : null
    format: swaggerPath != '' ? 'openapi-link' : null
    contact: {
      name: contact.name
      email: contact.email
    }
  }
}

resource common 'Microsoft.ApiManagement/service/apis/policies@2025-03-01-preview' = {
  parent: apis
  name: 'policy'
  properties: {
    value: policyContent != '' ? policyContent : commonPolicy
    format: 'rawxml'
  }
}

resource backend 'Microsoft.ApiManagement/service/backends@2025-03-01-preview' = if (false) {
  parent: apim
  name: 'backend-${name}'
  properties: {
    title: name
    description: 'description'
    url: serviceUrl
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

resource apimStatusHealth 'Microsoft.ApiManagement/service/apis/operations@2025-03-01-preview' = [
  for o in operations: if (swaggerPath == '') {
    parent: apis
    name: o.name
    properties: {
      displayName: o.displayName
      method: o.method
      urlTemplate: o.urlTemplate
      templateParameters: []
      description: o.description
      responses: []
    }
  }
]

resource apimStatusPolicyO 'Microsoft.ApiManagement/service/apis/operations/policies@2025-03-01-preview' = [
  for (o, i) in operations: if (swaggerPath == '') {
    parent: apimStatusHealth[i]
    name: 'policy'
    properties: {
      value: o.?policyContent != null
        ? o.?policyContent
        : '''
    <policies>
        <inbound>
            <base />
            <return-response>
                <set-status code="200" reason="OK" />
            </return-response>
        </inbound>
        <backend>
            <base />
        </backend>
        <outbound>
            <base />
        </outbound>
        <on-error>
            <base />
        </on-error>
    </policies>
    '''
      format: 'xml'
    }
  }
]

resource serviceProducts 'Microsoft.ApiManagement/service/products@2025-03-01-preview' = if (addProduct) {
  parent: apim
  name: name
  properties: {
    displayName: displayName
    description: description
    subscriptionRequired: false
    state: productState
  }
}

resource productApi 'Microsoft.ApiManagement/service/products/apis@2025-03-01-preview' = if (addProduct) {
  parent: serviceProducts
  name: name
}

resource productGuest 'Microsoft.ApiManagement/service/products/groups@2025-03-01-preview' = if (addProduct && productVisiableForGuests) {
  parent: serviceProducts
  name: 'guests'
}

resource groupGuest 'Microsoft.ApiManagement/service/groups@2025-03-01-preview' = if (addProduct && addGroup) {
  parent: apim
  name: 'grp-${name}'
  properties: {
    displayName: 'grp-${name}'
    description: description
    type: 'custom'
  }
}

resource productGroup 'Microsoft.ApiManagement/service/products/groups@2025-03-01-preview' = if (addProduct && addGroup) {
  parent: serviceProducts
  name: groupGuest.name
}
