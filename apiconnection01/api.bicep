targetScope = 'resourceGroup'

param location string = resourceGroup().location

resource azureblob01 'Microsoft.Web/connections@2016-06-01' = {
  name: 'api-azureblob01'
  location: location
  properties: {
    displayName: 'defaultName'
    api: {
      id: extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'azureblob')
    }
    parameterValues: {
      accountName: 'sttest01'//st.name
      accessKey: 'YU/o6FLTqpeDHrRz60jrITiAv7N4iNSJIuiwvlU6TAS0xU80uP29hmpV87PdMbi2QLMgJ5gTXTHd+AStPwo6gQ=='//storageAccount.listKeys().keys[0].value
      // name: 'managedIdentityAuth'
      // values: {}
    }
    }
}

resource managedId 'Microsoft.Web/connections@2016-06-01' = {
  name: 'api-id${env}01'
  location: location
  properties: {
    displayName: 'Managed identity for logic-runbook-${env}-01'
    api: {
      id: extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'azureautomation')
    }
    parameterValueSet: {
      name: 'oauthMI'
      values: {}
    }
  }
}
	
resource apiConnectionKeyVault 'Microsoft.Web/connections@2016-06-01' = {
  name: keyVaultApicName
  location: location
  properties: {
    displayName: keyVaultApicName
    api: {
      id: keyVaultApiReferenceId
    }
    parameterValueType: 'Alternative'
    alternativeParameterValues: {
      'vaultName': keyVaultName
    }
  }
}
	
resource apiConnectionServiceBus 'Microsoft.Web/connections@2016-06-01' = {
  name: serviceBusApicName
  location: location
  properties: {
    displayName: serviceBusApicName
    api: {
      id: serviceBusApiReferenceId
    }
    parameterValueSet: {
      name: 'managedIdentityAuth'
      values: {
        namespaceEndpoint: {
          'value': serviceBusNamespaceEndpoint
        }
      }
    }
  }
}

resource blobConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: 'blobConnectionName'
  location: location
  properties: {
    api: {
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'azureblob')
    }
    customParameterValues: {}
    displayName: 'blobConnectionName'
    parameterValueSet: {
      name: 'managedIdentityAuth'
      values: {}
    }
  }
}


resource azurequeues01 'Microsoft.Web/connections@2016-06-01' = {
  name: 'api-azurequeues01'
  location: location
  properties: {
    displayName: 'azurequeues01'
    api: {
      displayName: 'azurequeues01'
      id:subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'azurequeues')
    }
    parameterValues: {
      //storageaccount: staccountName
      //sharedkey: staccountKey //listKeys(storage_account.id, storage_account.apiVersion).keys[0].value
    }
  }
}

resource azuretables01 'Microsoft.Web/connections@2016-06-01' = {
  name: 'api-azuretables01'
  location: location
  properties: {
    displayName: 'azuretables01'
    api: {
      id: extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'azuretables')
    }
    
    parameterValues: {
      storageaccount: staccountName
      sharedkey: staccountKey
    }
    }
}

resource azureautomation01 'Microsoft.Web/connections@2016-06-01' = {
  name: 'api-azureautomation01'
  location: location
  properties: {
    displayName: 'api-azureautomation01'
    api: {
      id: extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'azureautomation')
    }
    parameterValues: {
      ////App registration client ID
      'token:clientId': 'xxxxxxx-a830-4d9e-a9a8-xxxxxxx'
      'token:TenantId': empty(tenant().tenantId) ? tenant().tenantId : tenant().tenantId
      'token:grantType': 'client_credentials'
    }
  }
}

resource office36501 'Microsoft.Web/connections@2016-06-01' = {
  name: 'api-office36501'
  location: location
  properties: {
    displayName: 'passwordreminder@company.net'
    api: {
      id: extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'office365')
    }
    customParameterValues: {}
    nonSecretParameterValues: {}
  }
}

// create the related connection api
resource documentdb01 'Microsoft.Web/connections@2016-06-01' = {
  name: 'api-documentdb01'
  location: location
  properties: {
    displayName: 'api-documentdb01'
    parameterValues: {
      //databaseAccount: cosmosDbAccount.name
      //accessKey: listKeys(cosmosDbAccount.id, cosmosDbAccount.apiVersion).primaryMasterKey
    }
    api: {
      id: extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'documentdb')
    }
  }
}

resource sql01 'Microsoft.Web/connections@2016-06-01' = {
  name: 'api-sql01'
  location: location
  properties: {
    displayName: 'api-sql01'
    parameterValues: {
      server: 'servername'
      database: 'databasename'
      authType: 'basic'//
      username: 'user'
      password: 'password'
    }
    api: {
      id: extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'sql')
    }
  }
}

resource servicebus01 'Microsoft.Web/connections@2016-06-01' = {
  name: 'api-servicebus01'
  location: location
  properties: {
    displayName: 'servicebus01'     
    api: {
      description: 'Connect to Azure Serice Bus to send and receive messages'
      id:  extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'servicebus')
      }
      parameterValues: {
        //connectionString: listKeys(resourceId('Microsoft.ServiceBus/namespaces/authorizationRules', 'ServiceBusNamespace', 'RootManageSharedAccessKey'), '2017-04-01').primaryConnectionString
      }
    }
}

resource keyvault01 'Microsoft.Web/connections@2016-06-01' = {
  name: 'api-keyvault01'
  location: location
  properties: {
    displayName: 'keyvault'    
    api:{
      id: extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'keyvault')
        } 
    }
}

resource azureeventgrid01 'Microsoft.Web/connections@2016-06-01' = {
  name: 'api-azureeventgrid01'
  location: location
  properties: {
    displayName: 'azureeventgrid01'   
    parameterValues: {
      'token:clientId': 'xxxxxxx-a830-4d9e-a9a8-xxxxxxx'
      'token:clientSecret': 'dfbdfbbwr3443'
      'token:TenantId': empty(tenant().tenantId) ? tenant().tenantId : tenant().tenantId
      'token:grantType': 'client_credentials'
    } 
    api:{
      id: extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'azureeventgrid')
        } 
    }
}

resource sendGridConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: '${prefix}sndgrdconn'
  location: location
  properties: {
    displayName: '${prefix}sndgrdconn'
    api: {
      id: '${subscription().id}/providers/Microsoft.Web/locations/${location}/managedApis/sendgrid'
    }
    parameterValues: {
      apiKey: sendGridApiKey
    }
  }
}
