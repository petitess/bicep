targetScope = 'resourceGroup'

param name string
param location string
param virtualMachines array
param workspaceResourceId string
param actionGroupId string

 var tags = resourceGroup().tags

 //https://docs.microsoft.com/en-us/azure/network-watcher/network-watcher-create
//When you create or update a virtual network in your subscription, 
//Network Watcher will be enabled automatically in your Virtual Network's region.
//To opt out of Network Watcher automatic enablement, you can do so by running the following commands:
//Register-AzProviderFeature -FeatureName DisableNetworkWatcherAutocreation -ProviderNamespace Microsoft.Network
//Register-AzResourceProvider -ProviderNamespace Microsoft.Network
 
resource nw 'Microsoft.Network/networkWatchers@2022-07-01' = {
  name: name
  location: location
  tags: tags
  properties:{}
}

resource vmexisting 'Microsoft.Compute/virtualMachines@2022-08-01' existing = [for vm in virtualMachines:  {
  name: vm.name
  scope: resourceGroup('rg-${vm.name}')
}]

resource conmon 'Microsoft.Network/networkWatchers/connectionMonitors@2022-07-01' = [for (vm, i) in virtualMachines: if(vmexisting[i].name == 'vmabctest01') {
  name: '${vm.name}-GetHttpsGoogle'
  location: location
  parent: nw
  tags: tags
  properties: {
    endpoints: [
      {
        name: vm.name
        type: 'AzureVM'
        resourceId: vmexisting[i].id
      }
      {
        name: 'GoogleDNS'
        type: 'ExternalAddress'
        address: '8.8.8.8'
      }
    ]
    testConfigurations: [
      {
        name: '${vm.name}-https'
        protocol:  'Tcp'
        testFrequencySec: 30
        successThreshold: {
          checksFailedPercent: 10
        }
        tcpConfiguration: {
          port: 443
          disableTraceRoute: false
        }
      }
    ]
    testGroups: [
      {
        name: 'VmGetHttpsGoogle'
        destinations: [
          'GoogleDNS'
        ]
        testConfigurations: [
          '${vm.name}-https'
        ]
        sources: [
          vm.name
        ]
        disable: false
      }
    ]
    outputs: [
      {
        type: 'Workspace'
        workspaceSettings: {
          workspaceResourceId: workspaceResourceId
        }
      }
    ]
  }
}]

resource pingalert 'Microsoft.Insights/metricAlerts@2018-03-01' = [for (vm, i) in virtualMachines: if(vmexisting[i].name == 'vmabctest01') {
  name: '${vm.name}-pingDNSfail'
  location: 'global'
  properties: {
    enabled: true 
    evaluationFrequency: 'PT1M'
    severity: 2
    windowSize: 'PT5M'
    scopes: [
      conmon[i].id
    ]
    autoMitigate: true
    actions: [
      {
        actionGroupId: actionGroupId
      }
    ]
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'Metric1'
          operator: 'GreaterThan'
          threshold: 2  
          timeAggregation: 'Maximum'
          criterionType: 'StaticThresholdCriterion'
          metricName: 'TestResult'
          dimensions: [
            {
              name: 'SourceName'
              operator: 'Include' 
              values: [
                '*'
              ]
            }
            {
              name: 'DestinationName'
              operator: 'Include' 
              values: [
                '*'
              ]
            }
            {
              name: 'TestGroupName'
              operator: 'Include' 
              values: [
                '*'
              ]
            }
            {
              name: 'TestConfigurationName'
              operator: 'Include' 
              values: [
                '*'
              ]
            }
          ]
        }
      ]
    }
  }
}]

