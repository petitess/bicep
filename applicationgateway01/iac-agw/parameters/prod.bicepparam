using '../main.bicep'

param env = 'prod'
param tags = {
  product: 'app'
}

param agw = {
  name: 'agw-prod-01'
  privateip: '10.20.1.5'
  sslCertificates: [
    'CertName'
  ]
  sites: [
    {
      hostname: 'api.abcd.se'
      public: true
      pickHostNameFromBackendAddress: false //create private dns zone e.g. api.abcd.se and add custom domain to apim
      protocol: 'https'
      port: '443'
      priority: 1020
      backendAddresses: [
        {
          fqdn: 'apim-prod-abcd-01.azure-api.net'
        }
      ]
      probePath: '/status-0123456789abcdef'
      probeHost: 'apim-prod-abcd-01.azure-api.net' //should be e.g. api.abcd.se when custom domain is verified
      probeStatus: [
        '200-400'
      ]
      waf: {
        mode: 'Prevention'
        requestBodyCheck: false
        customRules: []
        managedRules: {
          managedRuleSets: [
            {
              ruleSetType: 'OWASP'
              ruleSetVersion: '3.2'
              ruleGroupOverrides: []
            }
          ]
        }
      }
    }
  ]
}
