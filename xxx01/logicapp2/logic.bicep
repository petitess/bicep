param location string = resourceGroup().location
param roleDefinitionId string = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' //Default as Storage Blob Data Contributor role

var storageAccountName = 'mystorageaccoun561561'
//var logicAppDefinition = json(loadTextContent('definition.json'))

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: true
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
}

resource blobConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: 'blobConnectionName'
  location: location
  kind: 'V1'
  properties: {
    alternativeParameterValues: {}
    api: {
      id: extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'azureblob')
      //id: 'subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/azureblob'
    }
    customParameterValues: {}
    displayName: 'defaultName'
    parameterValueSet: {
      name: 'managedIdentityAuth'
      values: {}
    }
  }
}

resource logicapp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: 'logicAppName'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {
          }
          type: 'Object'
        }
      }
    }//logicAppDefinition.definition
    parameters: {
      '$connections': {
        value: {
          azureblob: {
            connectionId: blobConnection.id
            connectionName: 'azureblob'
            id: extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'azureblob')
            connectionProperties: {
              authentication: {
                type: 'ManagedServiceIdentity'
              }
            }
          }
        }
      }
      // 'storageAccount': {
      //   value: storageAccountName
      // }
    }
  }
}

resource logicAppStorageAccountRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  scope: storageAccount
  name: guid('ra-logicapp-${roleDefinitionId}')
  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: logicapp.identity.principalId
  }
}

output a string = 'subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/azureblob'
output b string = extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'azureblob')


//resource sdf provide
