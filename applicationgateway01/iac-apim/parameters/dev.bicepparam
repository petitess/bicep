using '../main.bicep'

param env = 'dev'
param tags = {
  Environment: 'Development'
  Company: 'ABCD'
}

param apim = {
  initialDeploy: true
  skuName: 'Developer'
  capacity: 1
  publisherName: 'ABCD'
  publisherEmail: 'karol@abcd.se'
  virtualNetworkType: 'Internal'
  ipAddress: '10.20.1.71'
  hostnameApi: 'api-dev.abcd.se'
  hostnamePortal: 'portal-api-dev.abcd.se'
  hostnameManagement: 'management-api-dev.abcd.se'
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
    'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls13': 'true'
    'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30': 'true'
  }
}

param apis = [
  {
    name: 'func-api-dev'
    displayName: 'Func API'
    description: 'Data API.'
    subscriptionRequired: false
    serviceUrl: 'https://func-apim-dev-01.azurewebsites.net/api/'
    path: 'func/'
    swaggerPath: 'swagger.json'
    isCurrent: true
    roles: ''
    policyContent: ''
    contact: {
      name: 'Support'
      email: 'support@abcd.com'
    }
    //   roles: '''
    //     <value>role.one</value>
    //   '''
  }
]
