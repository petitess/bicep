using '../main.bicep'

param environment = 'dev'
param config = {
  product: 'infra'
  location: 'we'
  tags: {
    Product: 'Common Infrastructure'
    Environment: 'Development'
    CostCenter: '9100'
  }
  sslCertificates: [
    // 'abc-com'
  ]
  frontdoorEndpoints: [
    {
      fdeName: 'apim-dev'
      appFqdn: 'apim-abc-infra-apim-dev-we-01.azure-api.net'
      customDomain: ''
      certificateName: ''
      DnsZoneName: ''
      deployCNAME: false
      isCompressionEnabled: false
      queryStringCachingBehavior: 'IgnoreQueryString'
      customRules: []
      ruleGroupOverrides: []
      rules: [
        {
          name: 'apimheader'
          properties: {
            order: 0
            conditions: [
              {
                name: 'RequestUri'
                parameters: {
                  typeName: 'DeliveryRuleRequestUriConditionParameters'
                  operator: 'Contains'
                  negateCondition: false
                  matchValues: [
                    'apim'
                  ]
                  transforms: [
                    'Lowercase'
                  ]
                }
              }
            ]
            actions: [
              {
                name: 'ModifyRequestHeader'
                parameters: {
                  typeName: 'DeliveryRuleHeaderActionParameters'
                  headerAction: 'Append'
                  headerName: 'waf-apim'
                  value: '18344099-6885-5ef2-abc7-97c86801076b'
                }
              }
            ]
            matchProcessingBehavior: 'Continue'
          }
        }
      ]
    }
  ]
}
