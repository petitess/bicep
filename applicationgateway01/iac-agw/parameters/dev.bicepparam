using '../main.bicep'

param env = 'dev'
param tags = {
  product: 'app'
}

param agw = {
  name: 'agw-dev-01'
  privateip: '10.10.1.5'
  sslCertificates: [
    'CertName'
  ]
  sites: [
    {
      hostname: 'api-dev.abcd.se'
      public: true
      pickHostNameFromBackendAddress: true
      protocol: 'https'
      port: '443'
      priority: 1020
      backendAddresses: [
        {
          fqdn: 'apim-dev-abcd-01.azure-api.net'
        }
      ]
      probePath: '/status-0123456789abcdef'
      probeHost: 'apim-dev-abcd-01.azure-api.net'
      probeStatus: [
        '200-400'
      ]
      waf: {
        mode: 'Prevention'
        requestBodyCheck: false
        customRules: [
          // {
          //   name: 'GeolocationAndIP'
          //   priority: 100
          //   ruleType: 'MatchRule'
          //   action: 'Block'
          //   matchConditions: [
          //     {
          //       matchVariables: [
          //         {
          //           variableName: 'RemoteAddr'
          //         }
          //       ]
          //       operator: 'GeoMatch'
          //       negationConditon: true
          //       matchValues: [
          //         'SE'
          //       ]
          //       transforms: []
          //     }
          //   ]
          // }
        ]
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
