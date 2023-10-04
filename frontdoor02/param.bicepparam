using 'main.bicep'

param environment = 'dev'
param config = {
  product: 'infra'
  location: 'sc'
  tags: {
    Product: 'Common Infrastructure'
    Environment: 'Development'
    CostCenter: '1000'
  }
  frontdoorEndpoints: [
    {
      appName: 'app-xxx12'
      appFqdn: 'app-xxx12.azurewebsites.net'
      appRg: 'rg-app-afd'
      resourceType: 'Microsoft.Web/sites'
      appGroupId: ''//'sites'
      customDomain: ''//'appx.domain.cz'
      DnsZoneName: 'domain.cz'
      customRules: []
      ruleGroupOverrides: [
        {
          ruleGroupName: 'RCE'
          rules: [
            {
              ruleId: '932180'
              enabledState: 'Disabled'
            }
          ]
        }
      ]
    }
    {
      appName: 'stxxxx12'
      appFqdn: 'stxxxx12.z6.web.core.windows.net'
      appRg: 'rg-st-02'
      resourceType: 'Microsoft.Storage/storageAccounts'
      appGroupId: ''//'web'
      customDomain: ''
      DnsZoneName: 'domain.cz'
      customRules: []
      ruleGroupOverrides: []
    }
  ]
}
