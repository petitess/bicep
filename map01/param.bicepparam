using './main.bicep'

param param = {
  location: 'SwedenCentral'
  locationAlt: 'WestEurope'
  tags: {
    Application: 'Infra'
    Environment: 'Prod'
  }
  pathRules: [
    {
      name: 'oauth'
      site: 'extapi-app'
      site2: 'extapi-app'
      probePath: '/xxxxxx-48cc-4b99-96ce-xxxxxxx/b2c_1a_ClientCredentialsFlow/v2.0/.well-known/openid-configuration'
      pickHostNameFromBackendAddress: true
      paths: [
        '/oauth2/v2.0/token'
      ]
      backendAddresses: [
        {
          fqdn: 'login-utv.xxxx.com'
        }
      ]
      rewriteRuleSet: {
        actionSet: {
          urlConfiguration: {
            modifiedPath: '/xxxauthutv.onmicrosoft.com/B2C_1A_ClientCredentialsFlow/oauth2/v2.0/token'
            modifiedQueryString: '?scope=https%3A%2F%2Fxxxauthutv.onmicrosoft.com%2Fapi%2F.default'
            reroute: false
          }
        }
      }
      waf: {
        ruleGroupOverrides: [
          {
            ruleGroupName: 'REQUEST-931-APPLICATION-ATTACK-RFI'
            rules: [
              {
                ruleId: '931130'
                state: 'Disabled'
              }
            ]
          }
        ]
        customRules: []
      }
    }
    {
      name: 'projectstaffing'
      site: 'extapi-app'
      site2: 'extapi-app'
      probePath: '/health'
      pickHostNameFromBackendAddress: true
      paths: [
        '/projectstaffing/*'
      ]
      backendAddresses: [
        {
          fqdn: 'app-projectstaffing-extapi-xxx-dev-we-01.azurewebsites.net'
        }
      ]
    }
    {
      name: 'access'
      site: 'extapi-app'
      site2: 'xextapi-app'
      probePath: '/health'
      pickHostNameFromBackendAddress: true
      paths: [
        '/projectstaffing/*'
      ]
      backendAddresses: [
        {
          fqdn: 'app-access-extapi-api-xxx-dev-we-01.azurewebsites.net'
        }
      ]
    }
  ]
}
