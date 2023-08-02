using 'main.bicep'

param env = 'dev'
param param = {
  location: 'SwedenCentral'
  locationAlt: 'WestEurope'
  tags: {
    Application: 'Infra'
    Environment: 'Development'
  }
  st: [
    {
      name: 'stsft${env}sc01'
      sku: 'Standard_LRS'
      kind: 'StorageV2'
      networkAcls: {
        defaultAction: 'Allow'
        bypass: 'AzureServices'
        resourceAccessRules: []
        ipRules: []
      }
      fileShares: []
      containers: [
        {
          name: 'container01'
        }
      ]
    }
  ]
}
