param env string
param location string = resourceGroup().location
param tags object = resourceGroup().tags

var my_table = 'mycommand'
var dataStructure = [
  {
    name: 'RawData'
    type: 'string'
  }
  {
    name: 'TimeGenerated'
    type: 'datetime'
  }
  {
    name: 'Application'
    type: 'string'
  }
  {
    name: 'My_prop'
    type: 'string'
  }
  {
    name: 'Dev'
    type: 'string'
  }
  {
    name: 'Subscription'
    type: 'string'
  }
  {
    name: 'Location'
    type: 'string'
  }
]

resource log 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'log-${env}-01'
  location: location
  tags: tags
  properties: {
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource table 'Microsoft.OperationalInsights/workspaces/tables@2022-10-01' = {
  parent: log
  name: '${my_table}_CL'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: '${my_table}_CL'
      columns: dataStructure
    }
    retentionInDays: 30
  }
}

resource dcrend 'Microsoft.Insights/dataCollectionEndpoints@2023-03-11' = {
  name: 'dce-${env}-01'
  location: location
  tags: tags
  properties: {
    configurationAccess: {}
    logsIngestion: {}
    metricsIngestion: {}
    networkAcls: {
      publicNetworkAccess: 'Enabled'
    }
  }
}

resource dcr 'Microsoft.Insights/dataCollectionRules@2023-03-11' = {
  name: 'dcr-${env}-01'
  location: location
  tags: tags
  properties: {
    dataCollectionEndpointId: dcrend.id
    streamDeclarations: {
      'Custom-${my_table}_CL': {
        columns: dataStructure
      }
    }
    dataSources: {}
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: log.id
          name: log.name
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Custom-${my_table}_CL'
        ]
        destinations: [
          log.name
        ]
        transformKql: 'source'
        outputStream: 'Custom-${my_table}_CL'
      }
    ]
  }
}
