param env string
param location string = resourceGroup().location
param tags object = resourceGroup().tags
@description('To make API call you need the role Monitoring Metrics Publisher')
param rbac {
  role: ('Contributor' | 'Reader' | 'Monitoring Metrics Publisher')
  principalId: string
  principalType: ('Device' | 'ForeignGroup' | 'Group' | 'ServicePrincipal' | 'User')?
}[] = []

var rolesList = {
  Contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  Reader: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
  'Monitoring Metrics Publisher': '3913510d-42f4-4e42-8a64-420c390055eb'
}
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

resource log 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
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

resource table 'Microsoft.OperationalInsights/workspaces/tables@2025-02-01' = {
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

resource rbacR 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (r, i) in rbac: if (rbac != []) {
    name: guid(resourceGroup().id, r.principalId, r.role, string(i))
    properties: {
      principalId: r.principalId
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleAssignments', rolesList[r.role])
      principalType: r.?principalType ?? 'ServicePrincipal'
    }
  }
]
