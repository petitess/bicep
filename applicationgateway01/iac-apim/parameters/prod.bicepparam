using '../main.bicep'

param env = 'prod'
param tags = {
  Environment: 'Production'
  Company: 'ABCD'
}

param apim = {
  initialDeploy: true
  skuName: 'StandardV2'
  capacity: 1
  publisherName: 'ABCD'
  publisherEmail: 'karol@abcd.se'
  virtualNetworkType: 'External'
  ipAddress: '10.20.1.71'
  hostnameApi: 'api.abcd.se'
  hostnamePortal: 'portal-api.abcd.se'
  sslCertificates: [
     'CertName'
  ]
  customProperties: {
    'Microsoft.WindowsAzure.ApiManagement.Gateway.Protocols.Server.Http2': 'true'
    'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10': 'false'
    'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11': 'false'
    'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Ssl30': 'true'
    'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10': 'false'
    'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11': 'false'
    'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30': 'true'
  }
}
param apis = [
  {
    name: 'apim-status'
    displayName: 'APIM Status'
    description: 'APIM Status'
    subscriptionRequired: false
    serviceUrl: 'https://apim-prod-abcd-01.azure-api.net/'
    path: 'health'
    isCurrent: true
    roles: ''
    addProduct: true
    productState: 'published'
    productVisiableForGuests: false
    addGroup: true
    policyContent: '''
    <policies>
      <inbound>
          <base />
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
    operations: [
      {
        name: 'status'
        displayName: 'Status'
        method: 'GET'
        urlTemplate: '/status-0123456789abcdef'
        description: 'Returns 200 OK — used as a health/liveness check'
        policyContent: '''
        <policies>
          <inbound>
            <base />
            <return-response>
              <set-status code="200" reason="OK" />
              <set-header name="Content-Type" exists-action="override">
                <value>application/json</value>
              </set-header>
              <set-body>{"status":"healthy"}</set-body>
            </return-response>
          </inbound>
          <backend>
            <base />
          </backend>
          <outbound>
            <base />
            <set-header name="x-powered-by" exists-action="delete" />
            <set-header name="x-aspnet-version" exists-action="delete" />
          </outbound>
          <on-error>
            <base />
          </on-error>
        </policies>
        '''
      }
    ]
    contact: {
      name: 'Support'
      email: 'support@abcd.com'
    }
  }
]
