targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param idId string = ''
param idName string = ''
param timestamp string = utcNow()
param kvName string
param vm array
param vmadc array

var vmName = [for virtualMachine in vm: {
  name: virtualMachine.name
}]

var vmNameAdc = [for virtualMachine in vmadc: {
  name: virtualMachine.name
}]

resource script 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: name
  location: location
  tags: tags
  identity: empty(idName) ? null : {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${idId}': {}
    }
  }
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '5.0'
    retentionInterval: 'PT1H'
    timeout: 'PT10M'
    cleanupPreference: 'Always'
    forceUpdateTag: timestamp
    scriptContent: loadTextContent('../scripts/secret.ps1')
    environmentVariables: [
      {
        name: 'KeyVault'
        value: kvName
      }
      {
        name: 'VirtualMachines'
        value: string(vmName)
      }
      {
        name: 'VirtualMachinesAdc'
        value: string(vmNameAdc)
      }
    ]
  }
}

output id string = script.id
output name string = script.name
output adminUsername string = script.properties.outputs.adminUsername
