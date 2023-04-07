param prefix string
param location string
param tags object
param groupPrefix array
param utc string = utcNow()

var AdGroups = [for grp in groupPrefix: {
  prefix: grp
}]

resource id 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'id-script-${prefix}-01'
  location: location
  tags: tags
}

resource script 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'script-${prefix}-01'
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
    azPowerShellVersion: '5.0'
    retentionInterval: 'PT1H'
    timeout: 'PT10M'
    cleanupPreference: 'Always'
    forceUpdateTag: utc
    scriptContent: loadTextContent('./groups.ps1')
    environmentVariables: [
      {
        name: 'AdGroups'
        value: string(AdGroups)
      }
    ]
  }
}
