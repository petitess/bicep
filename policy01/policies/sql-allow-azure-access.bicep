targetScope = 'subscription'

param effect (
  | 'addToNetworkGroup'
  | 'append'
  | 'audit'
  | 'auditIfNotExists'
  | 'deny'
  | 'denyAction'
  | 'deployIfNotExists'
  | 'disabled'
  | 'manual'
  | 'modify'
  | 'mutate') = 'auditIfNotExists'

param mode ('All'
| 'Indexed'
| 'Microsoft.Kubernetes.Data'
| 'Microsoft.CustomerLockbox.Data'
| 'Microsoft.KeyVault.Data'
| 'Microsoft.MachineLearningServices.v2.Data'
| 'Microsoft.ContainerService.Data'
| 'Microsoft.DataCatalog.Data'
| 'Microsoft.DataFactory.Data'
| 'Microsoft.Network.Data'
| 'Microsoft.MachineLearningServices.Data'
| 'Microsoft.LoadTestService.Data'
| 'Microsoft.Synapse.Data'
| 'Microsoft.ManagedHSM.Data') = 'All'

resource policy 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'SQL1'
  properties: {
    description: 'Allow Azure services and resources to access this server must be set to yes'
    displayName: 'SQL1: Allow Azure services and resources to access this server must be set to yes'
    mode: mode 
    policyType: 'Custom'
    version: '1.0.0'
    versions: [
      '1.0.0'
    ]
    metadata: {
      category: 'Sql'
    }
    parameters: {
      effect: {
        allowedValues: [
          'AuditIfNotExists'
          'Deny'
        ]
        defaultValue: 'AuditIfNotExists'
        metadata: {
          additionalProperties: null
          assignPermissions: null
          description: 'Activate or deactivate the execution of the policy'
          displayName: 'Effect'
          strongType: null
        }
        type: 'String'
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            equals: 'Microsoft.Sql/servers'
            field: 'type'
          }
          {
            equals: 'Enabled'
            field: 'Microsoft.Sql/servers/publicNetworkAccess'
          }
        ]
      }
      then: {
        details: {
          existenceCondition: {
            anyOf: [
              {
                equals: '0.0.0.0'
                field: 'Microsoft.Sql/servers/firewallRules/startIpAddress'
              }
              {
                equals: '0.0.0.0'
                field: 'Microsoft.Sql/servers/firewallRules/endIpAddress'
              }
            ]
          }
          type: 'Microsoft.Sql/servers/firewallRules'
        }
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
