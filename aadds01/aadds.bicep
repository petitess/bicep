targetScope = 'resourceGroup'


param name string
param subnetId string
param location string 
param domainName string
@allowed([
  'Standard'
  'Enterprise'
  'Premium'
])
param sku string
param notificationSettings object

resource ds  'Microsoft.AAD/domainServices@2021-05-01' = {
  name: name
  location: location
  properties: {
    sku: sku
    filteredSync: 'Disabled'
    domainConfigurationType: 'FullySynced'
    domainName: domainName
    domainSecuritySettings: {
      kerberosArmoring:  'Disabled'
      kerberosRc4Encryption: 'Enabled'
      tlsV1: 'Enabled'
      ntlmV1: 'Disabled'
      syncOnPremPasswords: 'Enabled'
      syncNtlmPasswords: 'Enabled'
    }
    replicaSets: [
      {
        subnetId: subnetId
        location: location
      }
    ]
    notificationSettings: notificationSettings
  }
}

