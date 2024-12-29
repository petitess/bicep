targetScope = 'subscription'

param idId string = ''
param location string = deployment().location

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'RES1'
  properties: {
    displayName: 'RES1: Production ressources must be locked against deletion'
    description: 'Production ressources must be locked against deletion'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'All'
    }
    parameters: {
      effect: {
        allowedValues: [
          'AuditIfNotExists'
          'Disabled'
        ]
        defaultValue: 'AuditIfNotExists'
        metadata: {
          description: 'Activate or deactivate the execution of the policy'
          displayName: 'Effect'
        }
        type: 'String'
      }
      excludedResourceGroups: {
        allowedValues: [
          'rg-dl-abcd-aks-*'
          'rg-dl-abcd-databricks-*'
          'rg-dp-abr-*-syws-prd-frc'
          'syws-rg-dp-abr-*-prd-frc'
          'rg-dp-abcd-vnet-*-frc'
        ]
        defaultValue: [
          'rg-dl-abcd-aks-*'
          'rg-dl-abcd-databricks-*'
          'rg-dp-abr-*-syws-prd-frc'
          'syws-rg-dp-abr-*-prd-frc'
          'rg-dp-abcd-vnet-*-frc'
        ]
        metadata: {
          description: 'The list of excluded RSG used on aks or databricks'
        }
        type: 'array'
      }
      listOfResources: {
        allowedValues: [
          'Microsoft.AppConfiguration/configurationStores'
          'Microsoft.App/ContainerApps'
          'Microsoft.App/managedEnvironments'
          'Microsoft.CognitiveServices/accounts'
          'Microsoft.ContainerRegistry/registries'
          'Microsoft.Search/searchServices'
          'Microsoft.Databricks/workspaces'
          'Microsoft.DataFactory/factories'
          'Microsoft.Devices/provisioningServices'
          'Microsoft.Kusto/clusters'
          'Microsoft.Network/applicationGateways'
          'Microsoft.ContainerService/ManagedClusters'
          'Microsoft.MachineLearningServices/workspaces'
          'Microsoft.Network/privateEndpoints'
          'Microsoft.ApiManagement/service'
          'Microsoft.Synapse/workspaces'
          'Microsoft.Automation/automationAccounts'
          'Microsoft.CDN/profiles'
          'Microsoft.Cache/Redis'
          'Microsoft.DocumentDB/databaseAccounts'
          'Microsoft.DBforMySQL/flexibleServers'
          'Microsoft.DBforPostgreSQL/flexibleServers'
          'Microsoft.DBforPostgreSQL/servers'
          'Microsoft.DBforMySQL/servers'
          'Microsoft.Devices/IotHubs'
          'Microsoft.Sql/servers'
          'Microsoft.DataMigration/services'
          'Microsoft.EventGrid/domains'
          'Microsoft.EventGrid/namespaces'
          'Microsoft.EventGrid/systemTopics'
          'Microsoft.EventGrid/topics'
          'Microsoft.EventHub/namespaces'
          'Microsoft.Network/frontDoors'
          'Microsoft.Web/sites'
          'Microsoft.Network/loadBalancers'
          'Microsoft.Logic/workflows'
          'Microsoft.Sql/managedInstances'
          'Microsoft.Network/natGateways'
          'Microsoft.Purview/accounts'
          'Microsoft.ServiceBus/namespaces'
          'Microsoft.SignalRService/SignalR'
          'Microsoft.StreamAnalytics/streamingjobs'
          'Microsoft.Storage/storageAccounts'
          'Microsoft.KeyVault/vaults'
          'Microsoft.Compute/virtualMachines'
          'Microsoft.ClassicCompute/virtualMachines'
          'Microsoft.DigitalTwins/digitalTwinsInstances'
          'Microsoft.DBforPostgreSQL/serverGroupsv2'
          'Microsoft.AnalysisServices/servers'
          'Microsoft.Kusto/clusters'
          'Microsoft.Purview/Accounts'
          'Microsoft.StreamAnalytics/streamingjobs'
          'Microsoft.RecoveryServices/vaults'
          'Microsoft.HybridCompute/machines'
          'microsoft.Dashboard/grafana'
          'Microsoft.Insights/components'
        ]
        defaultValue: [
          'Microsoft.AppConfiguration/configurationStores'
          'Microsoft.App/ContainerApps'
          'Microsoft.App/managedEnvironments'
          'Microsoft.CognitiveServices/accounts'
          'Microsoft.ContainerRegistry/registries'
          'Microsoft.Search/searchServices'
          'Microsoft.Databricks/workspaces'
          'Microsoft.DataFactory/factories'
          'Microsoft.Devices/provisioningServices'
          'Microsoft.Kusto/clusters'
          'Microsoft.Network/applicationGateways'
          'Microsoft.ContainerService/ManagedClusters'
          'Microsoft.MachineLearningServices/workspaces'
          'Microsoft.Network/privateEndpoints'
          'Microsoft.ApiManagement/service'
          'Microsoft.Synapse/workspaces'
          'Microsoft.Automation/automationAccounts'
          'Microsoft.CDN/profiles'
          'Microsoft.Cache/Redis'
          'Microsoft.DocumentDB/databaseAccounts'
          'Microsoft.DBforMySQL/flexibleServers'
          'Microsoft.DBforPostgreSQL/flexibleServers'
          'Microsoft.DBforPostgreSQL/servers'
          'Microsoft.DBforMySQL/servers'
          'Microsoft.Devices/IotHubs'
          'Microsoft.Sql/servers'
          'Microsoft.DataMigration/services'
          'Microsoft.EventGrid/domains'
          'Microsoft.EventGrid/namespaces'
          'Microsoft.EventGrid/systemTopics'
          'Microsoft.EventGrid/topics'
          'Microsoft.EventHub/namespaces'
          'Microsoft.Network/frontDoors'
          'Microsoft.Web/sites'
          'Microsoft.Network/loadBalancers'
          'Microsoft.Logic/workflows'
          'Microsoft.Sql/managedInstances'
          'Microsoft.Network/natGateways'
          'Microsoft.Purview/accounts'
          'Microsoft.ServiceBus/namespaces'
          'Microsoft.SignalRService/SignalR'
          'Microsoft.StreamAnalytics/streamingjobs'
          'Microsoft.Storage/storageAccounts'
          'Microsoft.KeyVault/vaults'
          'Microsoft.Compute/virtualMachines'
          'Microsoft.ClassicCompute/virtualMachines'
          'Microsoft.DigitalTwins/digitalTwinsInstances'
          'Microsoft.DBforPostgreSQL/serverGroupsv2'
          'Microsoft.AnalysisServices/servers'
          'Microsoft.Kusto/clusters'
          'Microsoft.Purview/Accounts'
          'Microsoft.StreamAnalytics/streamingjobs'
          'Microsoft.RecoveryServices/vaults'
          'Microsoft.HybridCompute/machines'
          'microsoft.Dashboard/grafana'
          'Microsoft.Insights/components'
        ]
        metadata: {
          description: 'The list of all resources who needs to have lock'
        }
        type: 'array'
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            anyof: [
              {
                equals: 'PRD'
                value: '''[toUpper(subscription().tags['environment'])]'''
              }
              {
                equals: 'PROD'
                value: '''[toUpper(subscription().tags['environment'])]'''
              }
              {
                like: '*-PRD'
                value: '''[toUpper(subscription().displayName)]'''
              }
              {
                equals: 'PRD'
                value: '''[split(toUpper(subscription().displayName), '-')[2]]'''
              }
            ]
          }
          {
            field: 'type'
            in: '''[parameters('listOfResources')]'''
          }
          {
            allOf: [
              {
                notContains: '-core'
                value: '''[split(field('id'), '/')[4]]'''
              }
              {
                field: 'name'
                notContains: '-core'
              }
            ]
          }
          {
            count: {
              name: 'allowedRSG'
              value: '''[parameters('excludedResourceGroups')]'''
              where: {
                like: '''[current('allowedRSG')]'''
                value: '''[resourceGroup().name]'''
              }
            }
            equals: 0
          }
        ]
      }
      then: {
        details: {
          existenceCondition: {
            equals: 'CanNotDelete'
            field: 'Microsoft.Authorization/locks/level'
          }
          type: 'Microsoft.Authorization/locks'
        }
        effect: '''[parameters('effect')]'''
      }
    }
  }
}

resource assignment 'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: 'assigment-${definition.name}'
  location: location
  properties: {
    displayName: 'assigment-${definition.properties.displayName}'
    description: definition.properties.description
    notScopes: []
    enforcementMode: 'Default'
    policyDefinitionId: definition.id
    parameters: {
      effect: {
        value: definition.properties.parameters['effect'].defaultValue
      }
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${idId}': {}
    }
  }
}
