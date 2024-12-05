targetScope = 'resourceGroup'

param name string
param tags object = resourceGroup().tags
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

resource entraDs 'Microsoft.AAD/domainServices@2022-12-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: sku
    filteredSync: 'Disabled'
    domainConfigurationType: 'FullySynced'
    domainName: domainName
    domainSecuritySettings: {
      kerberosArmoring: 'Disabled'
      kerberosRc4Encryption: 'Enabled'
      tlsV1: 'Enabled'
      ntlmV1: 'Disabled'
      syncOnPremPasswords: 'Enabled'
      syncNtlmPasswords: 'Enabled'
      channelBinding: 'Disabled'
      ldapSigning: 'Disabled'
      syncKerberosPasswords: 'Enabled'
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
