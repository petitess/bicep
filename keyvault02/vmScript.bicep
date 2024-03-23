targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param idName string = ''
param timestamp string = utcNow()
param kvName string
param vm array
param stName string
param snetId string

var vmName = [
  for virtualMachine in concat(vm): {
    name: virtualMachine.name
  }
]

resource id 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' existing = {
  name: idName
}

resource script 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: name
  location: location
  tags: tags
  identity: empty(idName)
    ? null
    : {
        type: 'UserAssigned'
        userAssignedIdentities: {
          '${id.id}': {}
        }
      }
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '9.7'
    retentionInterval: 'PT1H'
    timeout: 'PT10M'
    cleanupPreference: 'Always'
    forceUpdateTag: timestamp
    scriptContent: loadTextContent('./secret.ps1')
    storageAccountSettings: {
      storageAccountName: stName
    }
    containerSettings: {
      subnetIds: [
        {
          id: snetId
        }
      ]
    }
    environmentVariables: [
      {
        name: 'KeyVault'
        value: kvName
      }
      {
        name: 'VirtualMachines'
        value: string(vmName)
      }
    ]
  }
}

output id string = script.id
output name string = script.name
output adminUsername string = script.properties.outputs.adminUsername
