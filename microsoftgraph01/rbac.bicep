param roleAssignments {
  principalId: string?
  role: (
    | 'Contributor'
    | 'Owner'
    | 'Reader'
    | 'KeyVaultAdministrator'
    | 'KeyVaultSecretsUser'
    | 'KeyVaultCryptoUser'
    | 'NetworkContributor'
    | 'UserAccessAdministrator'
    | 'LogAnalyticsContributor'
    | 'BackupMUAOperator'
    | 'BackupMUAAdmin'
    | 'MonitoringMetricsPublisher'
    | 'AzureServiceBusDataOwner'
    | 'AppConfigurationDataOwner'
    | 'StorageBlobDataContributor')
  principalType: resourceInput<'Microsoft.Authorization/roleAssignments@2022-04-01'>.properties.principalType?
  description: string?
}[]

var rolesList = {
  Contributor: roleDefinitions('Contributor').id
  Owner: roleDefinitions('Owner').id
  Reader: roleDefinitions('Reader').id
  KeyVaultAdministrator: roleDefinitions('Key Vault Administrator').id
  KeyVaultSecretsUser: roleDefinitions('Key Vault Secrets User').id
  KeyVaultCryptoUser: roleDefinitions('Key Vault Crypto User').id
  NetworkContributor: roleDefinitions('Network Contributor').id
  UserAccessAdministrator: roleDefinitions('User Access Administrator').id
  LogAnalyticsContributor: roleDefinitions('Log Analytics Contributor').id
  BackupMUAOperator: roleDefinitions('Backup MUA Operator').id
  BackupMUAAdmin: roleDefinitions('Backup MUA Admin').id
  MonitoringMetricsPublisher: roleDefinitions('Monitoring Metrics Publisher').id
  AzureServiceBusDataOwner: roleDefinitions('Azure Service Bus Data Owner').id
  AppConfigurationDataOwner: roleDefinitions('App Configuration Data Owner').id
  StorageBlobDataContributor: roleDefinitions('Storage Blob Data Contributor').id
}

resource rbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (r, i) in roleAssignments: if (r.?principalId != null) {
    name: guid(subscription().id, r.?principalId, rolesList[r.role], resourceGroup().id)
    properties: {
      principalId: r.?principalId
      principalType: r.?principalType ?? 'ServicePrincipal'
      description: r.?description
      roleDefinitionId: rolesList[r.role]
    }
  }
]
