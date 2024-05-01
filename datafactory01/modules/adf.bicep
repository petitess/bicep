param name string
param location string
param tags object
param rgDns string
param snetId string
@secure()
param sqlPass string
param sqlName string
param stName string
param stId string
param accountKey string
param stDlName string
param stMonitorName string
param kvName string
param dbwUrl string = ''
param dbwId string = ''
param synapseConnectionString string
param privateEndpoints array = [
  'datafactory'
  'portal'
]

resource adf 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
  }
}

resource vnet 'Microsoft.DataFactory/factories/managedVirtualNetworks@2018-06-01' = {
  name: 'default'
  parent: adf
  properties: {}
}

resource intSelfHosted 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' =
  if (true) {
    name: 'self-hosted-int-01'
    parent: adf
    properties: {
      type: 'SelfHosted'
    }
  }

resource intVnet 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' =
  if (true) {
    name: 'vnet-int-01'
    dependsOn: [
      vnet
    ]
    parent: adf
    properties: {
      type: 'Managed'
      managedVirtualNetwork: {
        referenceName: 'default'
        type: 'ManagedVirtualNetworkReference'
      }
      typeProperties: {
        computeProperties: {
          location: location
          dataFlowProperties: {
            computeType: 'General'
            cleanup: false
            coreCount: 8
            timeToLive: 10
          }
        }
      }
    }
  }

resource linkedServiceBlob 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: 'linked_st_blob'
  parent: adf
  properties: {
    type: 'AzureBlobStorage'
    connectVia: {
      referenceName: intVnet.name
      type: 'IntegrationRuntimeReference'
    }
    typeProperties: {
      serviceEndpoint: 'https://${stMonitorName}.blob.${environment().suffixes.storage}/'
      accountKind: 'StorageV2'
    }
  }
}

resource linkedServiceKv 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: 'linked_st_kv'
  parent: adf
  properties: {
    type: 'AzureKeyVault'
    connectVia: {
      referenceName: intVnet.name
      type: 'IntegrationRuntimeReference'
    }
    typeProperties: {
      baseUrl: 'https://${kvName}${environment().suffixes.keyvaultDns}/'
    }
  }
}

resource linkedServiceSqlMId 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: 'linked_sql_mid'
  parent: adf
  properties: {
    type: 'AzureSqlDatabase'
    connectVia: {
      referenceName: intVnet.name
      type: 'IntegrationRuntimeReference'
    }
    typeProperties: {
      connectionString: 'Integrated Security=False;Encrypt=True;Connection Timeout=30;Data Source=${sqlName}${az.environment().suffixes.sqlServerHostname};Initial Catalog=sqldb-adf-log'
    }
  }
}

resource linkedServiceSqlLogin 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: 'linked_sql_login'
  parent: adf
  properties: {
    type: 'AzureSqlDatabase'
    connectVia: {
      referenceName: intVnet.name
      type: 'IntegrationRuntimeReference'
    }
    typeProperties: {
      connectionString: 'integrated security=False;encrypt=True;connection timeout=30;data source=${sqlName}${az.environment().suffixes.sqlServerHostname};initial catalog=sqldb-datafabrik;user id=sqladmin;Password=${sqlPass}'
    }
  }
}

resource linkedServiceDlKey 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: 'linked_st_dl_access_key'
  parent: adf
  properties: {
    type: 'AzureBlobFS'
    typeProperties: {
      url: 'https://${stDlName}.dfs.${environment().suffixes.storage}/'
      accountKey: accountKey
    }
    connectVia: {
      referenceName: intVnet.name
      type: 'IntegrationRuntimeReference'
    }
  }
}

resource linkedServiceDlMid 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: 'linked_st_dl_mid'
  parent: adf
  properties: {
    type: 'AzureBlobFS'
    connectVia: {
      referenceName: intVnet.name
      type: 'IntegrationRuntimeReference'
    }
    typeProperties: {
      url: 'https://${stDlName}.dfs.${environment().suffixes.storage}/'
    }
  }
}

resource linkedServiceDlSecret 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: 'linked_st_dl_secret'
  parent: adf
  properties: {
    type: 'AzureBlobFS'
    typeProperties: {
      sasUri: {
        type: 'AzureKeyVaultSecret'
        store: {
          referenceName: linkedServiceKv.name
          type: 'LinkedServiceReference'
        }
        secretName: 'secret01'
      }
    }
    connectVia: {
      referenceName: intVnet.name
      type: 'IntegrationRuntimeReference'
    }
  }
}

resource linkedServiceRest 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: 'linked_st_rest'
  parent: adf
  properties: {
    type: 'RestService'
    connectVia: {
      referenceName: intVnet.name
      type: 'IntegrationRuntimeReference'
    }
    typeProperties: {
      url: '${environment().resourceManager}subscriptions/${subscription().subscriptionId}/resourceGroups/rg-infra-sys-dev-we-01?api-version=2023-07-01'
      authenticationType: 'ManagedServiceIdentity'

      aadResourceId: environment().resourceManager
    }
  }
}

resource linkedFileServer 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: 'linked_file_server'
  parent: adf
  properties: {
    type: 'FileServer'
    typeProperties: {
      host: '@{linkedService().base_path}'
      userId: '@{linkedService().remote_username}'
      password: {
        secretName: '@linkedService().remote_password_secret_name'
        store: {
          referenceName: linkedServiceKv.name
          type: 'LinkedServiceReference'
        }
        type: 'AzureKeyVaultSecret'
      }
    }
    parameters: {
      remote_username: {
        type: 'String'
        defaultValue: ''
      }
      remote_password_secret_name: {
        type: 'String'
        defaultValue: ''
      }
      base_path: {
        type: 'String'
        defaultValue: ''
      }
    }
    connectVia: {
      referenceName: intSelfHosted.name
      type: 'IntegrationRuntimeReference'
    }
  }
}

resource linkedDataBricksToken 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' =
  if (dbwUrl != null) {
    name: 'linked_databricks_token'
    parent: adf
    properties: {
      type: 'AzureDatabricks'
      connectVia: {
        referenceName: intVnet.name
        type: 'IntegrationRuntimeReference'
      }
      typeProperties: {
        domain: 'https://${dbwUrl}'
        existingClusterId: '0501-090748-vufu55l3' //created in the databricks
        accessToken: {
          secretName: 'dbw-token' //create in the databricks
          type: 'AzureKeyVaultSecret'
          store: {
            referenceName: linkedServiceKv.name
            type: 'LinkedServiceReference'
          }
        }
      }
    }
  }

resource linkedSynapse 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' =
  if (synapseConnectionString != null) {
    name: 'AzureSynapseAnalytics'
    parent: adf
    properties: {
      type: 'AzureSqlDW'
      connectVia: {
        referenceName: intVnet.name
        type: 'IntegrationRuntimeReference'
      }
      typeProperties: {
        connectionString: synapseConnectionString
      }
    }
  }

resource linkedDataBricksMid 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' =
  if (dbwUrl != null || dbwId != null) {
    name: 'linked_databricks_mid'
    parent: adf
    properties: {
      type: 'AzureDatabricks'
      connectVia: {
        referenceName: intVnet.name
        type: 'IntegrationRuntimeReference'
      }
      typeProperties: {
        domain: 'https://${dbwUrl}'
        //in the databricks: add existing service principal for adf (microsoft entra id managed) and add the service principal to admin group
        authentication: 'MSI'
        workspaceResourceId: dbwId
        existingClusterId: '0501-090748-vufu55l3' //created in the dbw
      }
    }
  }

resource mpep 'Microsoft.DataFactory/factories/managedVirtualNetworks/managedPrivateEndpoints@2018-06-01' = {
  name: stName
  parent: vnet
  properties: {
    privateLinkResourceId: stId
    groupId: 'dfs'
  }
}

resource ds1 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: 'ds_source_dim'
  parent: adf
  properties: {
    linkedServiceName: {
      referenceName: linkedServiceSqlMId.name
      type: 'LinkedServiceReference'
    }
    type: 'AzureSqlTable'
    parameters: {
      pSourceDs: {
        type: 'String'
        defaultValue: '@pipeline().parameters.pTable'
      }
    }
    folder: {
      name: 'Datatorg'
    }
    typeProperties: {
      schema: 'dbo'
      table: {
        value: '@concat(\'v_source_\', dataset().pSourceDs)'
        type: 'Expression'
      }
    }
  }
}

resource ds2 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: 'ds_destination_dim'
  parent: adf
  properties: {
    linkedServiceName: {
      referenceName: linkedServiceSqlMId.name
      type: 'LinkedServiceReference'
    }
    type: 'AzureSqlTable'
    parameters: {
      pSinkDs: {
        type: 'String'
        defaultValue: '@pipeline().parameters.pTable'
      }
    }
    folder: {
      name: 'Datatorg'
    }
    typeProperties: {
      schema: 'dim'
      table: {
        value: '@dataset().pSinkDs'
        type: 'Expression'
      }
    }
  }
}

resource p1 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: 'ppl-dim-commision'
  parent: adf
  dependsOn: [
    ds1
    ds2
  ]
  properties: {
    parameters: {
      pTable: {
        type: 'String'
        defaultValue: 'Commission'
      }
    }
    variables: {
      vStatus: {
        type: 'String'
        defaultValue: 'Succeeded'
      }
    }
    folder: {
      name: 'Datafabrik - Datatorg'
    }
    activities: loadJsonContent('pipeline01.json')
  }
}

resource pep 'Microsoft.Network/privateEndpoints@2023-09-01' = [
  for pep in privateEndpoints: {
    name: 'pep-${substring(name, 0, length(name) - 2)}${pep}${substring(name, length(name) - 2, 2)}'
    location: location
    tags: tags
    properties: {
      customNetworkInterfaceName: 'nic-pep-${substring(name, 0, length(name) - 2)}${pep}-${substring(name, length(name) - 2, 2)}'
      privateLinkServiceConnections: [
        {
          name: '${adf.name}-${pep}'
          properties: {
            privateLinkServiceId: adf.id
            groupIds: [
              pep
            ]
          }
        }
      ]
      subnet: {
        id: snetId
      }
    }
  }
]

resource dns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = [
  for (dns, i) in privateEndpoints: {
    name: 'default'
    parent: pep[i]
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-${dns}-core-windows-net'
          properties: {
            privateDnsZoneId: resourceId(
              rgDns,
              'Microsoft.Network/privateDnsZones',
              'privatelink.datafactory.azure.net'
            )
          }
        }
      ]
    }
  }
]

output principalId string = adf.identity.principalId
