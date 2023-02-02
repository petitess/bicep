targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param plan object
param vmSize string
//@secure()
param adminUsername string
//@secure()
param adminPass string
param imageReference object
param osDiskSizeGB int
param dataDisks array
param networkInterfaces array
param extloadbalancerpoolid string
param DeployIIS bool

param vnetname string
param vnetrg string

resource ss 'Microsoft.Compute/virtualMachineScaleSets@2022-11-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: vmSize
    tier: 'Standard'
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
    singlePlacementGroup: true
    orchestrationMode: 'Uniform'
    upgradePolicy: {
      mode: 'Manual'
    }
    virtualMachineProfile: {
      osProfile: {
        adminUsername: adminUsername
        adminPassword: adminPass
        computerNamePrefix: name
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
                  loadBalancerBackendAddressPools: interface.externalloadbalancer ? [
                    {
                      id: extloadbalancerpoolid
                    }
                  ] : []
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

resource scale 'Microsoft.Insights/autoscalesettings@2022-10-01' = {
  name: '${name}-autoscale'
  location: location
  properties: {
    enabled: true
    name: '${name}-autoscale'
    targetResourceUri: ss.id
    predictiveAutoscalePolicy: {
      scaleMode: 'Disabled'
    }
    profiles: [
      {
        name: 'ScaleOutScaleIn01'
        capacity: {
          default: '2'
          maximum: '5'
          minimum: '2'
        }
        rules: [
          {
            metricTrigger: {
              metricName: 'Percentage CPU'
              metricNamespace: 'microsoft.compute/virtualmachinescalesets'
              metricResourceUri: ss.id
              operator: 'GreaterThan'
              statistic: 'Average'
              threshold: 80
              timeAggregation: 'Average'
              timeGrain: 'PT1M'
              timeWindow: 'PT5M'
            }
            scaleAction: {
              cooldown: 'PT5M'
              direction: 'Increase'
              type: 'ChangeCount'
              value: '1'
            }
          }
          {
            metricTrigger: {
              metricName: 'Percentage CPU'
              metricNamespace: 'microsoft.compute/virtualmachinescalesets'
              metricResourceUri: ss.id
              operator: 'LessThan'
              statistic: 'Average'
              threshold: 50
              timeAggregation: 'Average'
              timeGrain: 'PT1M'
              timeWindow: 'PT5M'
            }
            scaleAction: {
              cooldown: 'PT5M'
              direction: 'Decrease'
              type: 'ChangeCount'
              value: '1'
            }
          }
        ]
      }
    ]
  }
}

resource virtualMachine_IIS 'Microsoft.Compute/virtualMachineScaleSets/extensions@2022-11-01' = if (DeployIIS) {
  name: 'IIS'
  parent: ss
  properties: {
    autoUpgradeMinorVersion: true
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.9'
    settings: {
      commandToExecute: 'powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path "C:\\inetpub\\wwwroot\\Default.htm" -Value $($env:computername)'
    }
  }
}
