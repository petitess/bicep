targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'AMG2'
  properties: {
    displayName: 'AMG2: Managed private endpoints must be used'
    description: 'Managed private endpoints must be used to setup a private connection between Azure Grafana and private supported Azure data sources'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'Grafana'
    }
    parameters: {
      effect: {
        allowedValues: [
          'Audit'
          'Deny'
          'Disabled'
        ]
        defaultValue: 'Audit'
        metadata: {
          description: 'Activate or deactivate the execution of the policy'
          displayName: 'Effect'
        }
        type: 'String'
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            equals: 'Microsoft.Dashboard/grafana'
            field: 'type'
          }
          {
            notIn: [
              'Microsoft.DocumentDB/databaseAccounts'
              'Microsoft.DBforPostgreSQL/serverGroupsv2'
              'Microsoft.Kusto/Clusters'
              'microsoft.insights/privatelinkscopes'
              'Microsoft.monitor/accounts'
              'Microsoft.Sql/managedInstances'
              'Microsoft.Sql/servers'
              'Microsoft.Network/privateLinkServices'
              'Microsoft.Databricks/workspaces'
              'Microsoft.DBforPostgreSQL/flexibleServers'
            ]
            value: '''[concat(split(field('Microsoft.Dashboard/grafana/managedPrivateEndpoints/privateLinkResourceId'),'/')[6],'/',split(field('Microsoft.Dashboard/grafana/managedPrivateEndpoints/privateLinkResourceId'),'/')[7])]'''
          }
        ]
      }
      then: {
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
