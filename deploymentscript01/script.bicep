param location string
param tags object = resourceGroup().tags
param affix string

//Assign Groups Administator and Owner to this identity
resource id 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'id-script-${affix}-01'
  location: location
  tags: tags
}

resource script 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'script-${affix}-01'
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${id.id}': {}
    }
  }
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '9.4'
    retentionInterval: 'PT1H'
    timeout: 'PT10M'
    cleanupPreference: 'Always'
    scriptContent: loadTextContent('./rbac.ps1')
    environmentVariables: [
      {
        name: 'SubId'
        value: subscription().subscriptionId
      }
      {
        name: 'EnvName'
        value: tags.Environment
      }
    ]
  }
}
