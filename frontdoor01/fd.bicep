targetScope = 'resourceGroup'

param param object
param name string

var tags = resourceGroup().tags

resource fd 'Microsoft.Network/frontDoors@2021-06-01' = {
  name: name
  location: 'global'
  tags: tags
  properties: {
     friendlyName: name
     enabledState: 'Enabled'
     frontendEndpoints: [
       {
        name: name
        properties: {
          hostName: '${name}.azurefd.net'
          sessionAffinityEnabledState: 'Disabled'
          sessionAffinityTtlSeconds: 0
        }
       }
     ]
     backendPools: [ 
      {
      name: name
      properties: {
        healthProbeSettings: {
          id: resourceId('Microsoft.Network/FrontDoors/healthProbeSettings', name, 'simple')
        }
        loadBalancingSettings: {
          id: resourceId('Microsoft.Network/FrontDoors/loadBalancingSettings', name, 'simple')
        }
        backends: [for (vm, i) in param.vmvnet01: {
          address: pip[i].properties.ipAddress
          enabledState: 'Enabled'
          httpPort: 80
          httpsPort: 443
          priority: 1
          weight: 50
        }]
      }
     }
    ]
     backendPoolsSettings: {
      enforceCertificateNameCheck: 'Disabled'
      sendRecvTimeoutSeconds: 30
     }
     routingRules: [
      {
        name: name
        properties: {
          enabledState: 'Enabled'
          acceptedProtocols: [
            'Http'
            'Https'
          ]
          patternsToMatch: [
            '/*'
          ]
          routeConfiguration: {
            '@odata.type': '#Microsoft.Azure.FrontDoor.Models.FrontdoorForwardingConfiguration'
            forwardingProtocol: 'MatchRequest'
            backendPool: {
              id: resourceId('Microsoft.Network/FrontDoors/BackendPools', name, name)
            }
          }
          frontendEndpoints: [
            {
              id: resourceId('Microsoft.Network/FrontDoors/FrontendEndpoints', name, name)
            }
          ]
        }
      }
     ]
     loadBalancingSettings: [
      {
        name: 'simple'
        properties: {
          sampleSize: 4
          successfulSamplesRequired: 2
        }
      }
     ]
     healthProbeSettings: [
      {
        name: 'simple'
        properties: {
          enabledState: 'Enabled'
          healthProbeMethod: 'HEAD'
          intervalInSeconds: 30
          path: '/'
          protocol: 'Http'
        }
      }
     ]
  }
}

resource vm1 'Microsoft.Compute/virtualMachines@2022-03-01' existing = [for (vm, i) in param.vmvnet01: {
  name: vm.name
  scope: resourceGroup('rg-${vm.name}')
}]

resource pip 'Microsoft.Network/publicIPAddresses@2021-03-01' existing = [for (interface, i) in param.vmvnet01.networkInterfaces: {
name: 'pip-${vm1[i].name}-nic-1'
 scope: resourceGroup('rg-${vm1[i].name}')
}]
