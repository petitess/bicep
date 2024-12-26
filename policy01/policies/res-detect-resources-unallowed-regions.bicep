targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'RES11'
  properties: {
    displayName: 'RES11: Detect resources deployed outside of allowed regions'
    description: 'Detect resources deployed outside of allowed regions'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'All'
    }
    parameters: {
      effect: {
        allowedValues: [
          'Audit'
          'Disabled'
        ]
        defaultValue: 'Audit'
        metadata: {
          description: 'Enable or disable the execution of the policy'
          displayName: 'Effect'
        }
        type: 'String'
      }
      resourceLocationList: {
        allowedValues: [
          'westeurope'
          'eastus'
          'brazilsouth'
          'centralindia'
          'southeastasia'
          'francecentral'
          'westeurope'
          'global'
        ]
        defaultValue: [
          'westeurope'
          'eastus'
          'brazilsouth'
          'centralindia'
          'southeastasia'
          'francecentral'
          'westeurope'
          'global'
        ]
        metadata: {
          description: 'The list of regions to exclude'
          displayName: 'The list of regions to exclude'
        }
        type: 'array'
      }
      resourceType: {
        allowedValues: [
          'Microsoft.AppConfiguration/configurationStores'
          'Microsoft.CognitiveServices/accounts'
          'Microsoft.ContainerRegistry/registries'
          'Microsoft.Search/searchServices'
          'Microsoft.Databricks/workspaces'
          'Microsoft.DataFactory/factories'
          'Microsoft.ContainerService/ManagedClusters'
          'Microsoft.MachineLearningServices/workspaces'
          'Microsoft.ApiManagement/service'
          'Microsoft.Synapse/workspaces'
          'Microsoft.DocumentDB/databaseAccounts'
          'Microsoft.DBforMySQL/flexibleServers'
          'Microsoft.DBforPostgreSQL/flexibleServers'
          'Microsoft.Sql/servers'
          'Microsoft.EventGrid/systemTopics'
          'Microsoft.Storage/storageAccounts/blobServices'
          'Microsoft.ServiceBus/namespaces'
          'Microsoft.Storage/storageAccounts'
          'Microsoft.Web/sites'
        ]
        defaultValue: [
          'Microsoft.AppConfiguration/configurationStores'
          'Microsoft.CognitiveServices/accounts'
          'Microsoft.ContainerRegistry/registries'
          'Microsoft.Search/searchServices'
          'Microsoft.Databricks/workspaces'
          'Microsoft.DataFactory/factories'
          'Microsoft.ContainerService/ManagedClusters'
          'Microsoft.MachineLearningServices/workspaces'
          'Microsoft.ApiManagement/service'
          'Microsoft.Synapse/workspaces'
          'Microsoft.DocumentDB/databaseAccounts'
          'Microsoft.DBforMySQL/flexibleServers'
          'Microsoft.DBforPostgreSQL/flexibleServers'
          'Microsoft.Sql/servers'
          'Microsoft.EventGrid/systemTopics'
          'Microsoft.Storage/storageAccounts/blobServices'
          'Microsoft.ServiceBus/namespaces'
          'Microsoft.Storage/storageAccounts'
          'Microsoft.Web/sites'
        ]
        metadata: {
          description: 'The list of resource types to monitor'
          displayName: 'The list of resource types to monitor'
        }
        type: 'array'
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'location'
            notIn: '''[parameters('resourceLocationList')]'''
          }
          {
            field: 'type'
            in: '''[parameters('resourceType')]'''
          }
        ]
      }
      then: {
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
