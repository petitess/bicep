param env string
param location string
param stName string
param accessKey string

var tags = resourceGroup().tags
var container = 'container01'
var folder = 'folder01'

resource api 'Microsoft.Web/connections@2016-06-01' = {
  name: 'api-blob${env}01'
  location: location
  tags: tags
  properties: {
    displayName: 'access-key'
    parameterValues: {
      accountName: stName
      accessKey: accessKey
    }
    api: {
      id: extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'azureblob')
    }
  }
}

resource logic 'Microsoft.Logic/workflows@2019-05-01' = {
  name: 'logic-copyblob-${env}-01'
  location: location
  properties: {
    state: 'Enabled'
    parameters: {
      '$connections': {
        value: {
          azureblob: {
            connectionId: api.id
            connectionName: 'azureblob'
            id: extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'azureblob')
          }
        }
      }
    }
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
      }
      triggers: {
        'When_a_blob_is_added_or_modified_(properties_only)_(V2)': {
          recurrence: {
            frequency: 'Second'
            interval: 20
          }
          evaluatedRecurrence: {
            frequency: 'Second'
            interval: 20
          }
          splitOn: '@triggerBody()'
          metadata: {
            'JTJmY29udGFpbmVyMDE=': '/${container}'
          }
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'azureblob\'][\'connectionId\']'
              }
            }
            method: 'get'
            path: '/v2/datasets/@{encodeURIComponent(encodeURIComponent(\'AccountNameFromSettings\'))}/triggers/batch/onupdatedfile'
            queries: {
              checkBothCreatedAndModifiedDateTime: false
              folderId: 'JTJmY29udGFpbmVyMDE='
              maxFileCount: 10
            }
          }
        }
      }
      actions: {
        'Create_blob_(V2)': {
          runAfter: {
            'Get_blob_content_using_path_(V2)': [
              'Succeeded'
            ]
          }
          type: 'ApiConnection'
          inputs: {
            body: '@body(\'Get_blob_content_using_path_(V2)\')'
            headers: {
              ReadFileMetadataFromServer: true
            }
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'azureblob\'][\'connectionId\']'
              }
            }
            method: 'post'
            path: '/v2/datasets/@{encodeURIComponent(encodeURIComponent(\'AccountNameFromSettings\'))}/files'
            queries: {
              folderPath: '/${container}/${folder}/'
              name: '@triggerBody()?[\'Name\']'
              queryParametersSingleEncoded: true
            }
          }
          runtimeConfiguration: {
            contentTransfer: {
              transferMode: 'Chunked'
            }
          }
        }
        'Get_blob_content_using_path_(V2)': {
          runAfter: {}
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'azureblob\'][\'connectionId\']'
              }
            }
            method: 'get'
            path: '/v2/datasets/@{encodeURIComponent(encodeURIComponent(\'AccountNameFromSettings\'))}/GetFileContentByPath'
            queries: {
              inferContentType: true
              path: '@triggerBody()?[\'Path\']'
              queryParametersSingleEncoded: true
            }
          }
        }
      }
      outputs: {}
    }
  }
}
