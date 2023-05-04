targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param plan object
param vmSize string
param capacity int
//@secure()
param adminUsername string
//@secure()
param adminPass string
param computerNamePrefix string
param imageReference object
param osDiskSizeGB int
param dataDisks array
param networkInterfaces array
param deployDevOpsAgent bool

param vnetname string
param vnetrg string

resource ss 'Microsoft.Compute/virtualMachineScaleSets@2022-11-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: vmSize
    tier: 'Standard'
    capacity: capacity
  }
  identity: {
    type: 'SystemAssigned'
  }
  plan: empty(plan) ? null : {
    name: plan.name
    product: plan.product
    publisher: plan.publisher
  }
  properties: {
    singlePlacementGroup: false
    orchestrationMode: 'Uniform'
    upgradePolicy: {
      mode: 'Manual'
    }
    virtualMachineProfile: {
      osProfile: {
        adminUsername: adminUsername
        adminPassword: adminPass
        computerNamePrefix: computerNamePrefix
        windowsConfiguration: {
          enableAutomaticUpdates: false
          provisionVMAgent: true
          patchSettings: {
            enableHotpatching: false
          }
          timeZone: 'W. Europe Standard Time'
        }
      }
      licenseType: 'Windows_Server'
      storageProfile: {
        osDisk: {
          createOption: 'FromImage'
          caching: 'ReadWrite'
          diskSizeGB: osDiskSizeGB
          managedDisk: {
            storageAccountType: 'Premium_LRS'
          }
        }
        imageReference: imageReference
        dataDisks: [for dataDisk in dataDisks: {
          lun: dataDisk.lun
          createOption: 'Empty'
          diskSizeGB: dataDisk.diskSizeGB
          caching: 'ReadWrite'
          managedDisk: {
            storageAccountType: dataDisk.storageAccountType
          }
        }]
      }
      networkProfile: {
        networkInterfaceConfigurations: [for (interface, i) in networkInterfaces: {
          name: '${name}-nic-${i + 1}'
          properties: {
            primary: interface.primary
            enableAcceleratedNetworking: interface.enableAcceleratedNetworking
            enableIPForwarding: interface.enableIPForwarding
            ipConfigurations: [
              {
                name: 'ipconfig${i + 1}'
                properties: {
                  subnet: {
                    id: resourceId(vnetrg, 'Microsoft.Network/virtualNetworks/subnets', vnetname, interface.subnet)
                  }
                }
              }
            ]
          }
        }]
      }
    }
  }
}

// resource scale 'Microsoft.Insights/autoscalesettings@2022-10-01' = {
//   name: '${name}-autoscale'
//   location: location
//   properties: {
//     enabled: true
//     name: '${name}-autoscale'
//     targetResourceUri: ss.id
//     predictiveAutoscalePolicy: {
//       scaleMode: 'Disabled'
//     }
//     profiles: [
//       {
//         name: 'ScaleOutScaleIn01'
//         capacity: {
//           default: '2'
//           maximum: '5'
//           minimum: '2'
//         }
//         rules: [
//           {
//             metricTrigger: {
//               metricName: 'Percentage CPU'
//               metricNamespace: 'microsoft.compute/virtualmachinescalesets'
//               metricResourceUri: ss.id
//               operator: 'GreaterThan'
//               statistic: 'Average'
//               threshold: 80
//               timeAggregation: 'Average'
//               timeGrain: 'PT1M'
//               timeWindow: 'PT5M'
//             }
//             scaleAction: {
//               cooldown: 'PT5M'
//               direction: 'Increase'
//               type: 'ChangeCount'
//               value: '1'
//             }
//           }
//           {
//             metricTrigger: {
//               metricName: 'Percentage CPU'
//               metricNamespace: 'microsoft.compute/virtualmachinescalesets'
//               metricResourceUri: ss.id
//               operator: 'LessThan'
//               statistic: 'Average'
//               threshold: 50
//               timeAggregation: 'Average'
//               timeGrain: 'PT1M'
//               timeWindow: 'PT5M'
//             }
//             scaleAction: {
//               cooldown: 'PT5M'
//               direction: 'Decrease'
//               type: 'ChangeCount'
//               value: '1'
//             }
//           }
//         ]
//       }
//     ]
//   }
// }

resource DevOps 'Microsoft.Compute/virtualMachineScaleSets/extensions@2022-11-01' = if (deployDevOpsAgent) {
  name: 'Microsoft.Azure.DevOps.Pipelines.Agent'
  parent: ss
  properties: {
    autoUpgradeMinorVersion: false
    publisher: 'Microsoft.VisualStudio.Services'
    type: 'TeamServicesAgent'
    typeHandlerVersion: '1.31'
    settings: {
      isPipelinesAgent: true
      agentFolder: 'C:\\agent'
      agentDownloadUrl: 'https://vstsagentpackage.azureedge.net/agent/3.220.0/vsts-agent-win-x64-3.220.0.zip'
      enableScriptDownloadUrl: 'https://vstsagenttools.blob.core.windows.net/tools/ElasticPools/Windows/17/enableagent.ps1'
    }
  }
}
