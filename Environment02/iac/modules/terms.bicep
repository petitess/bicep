targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param idId string
param idName string

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
    scriptContent: '''
    #!/usr/bin/env pwsh

    Connect-AzAccount -Identity
   
    $terms = Get-AzMarketplaceTerms -Publisher citrix -Product netscalervpx-131 -Name netscalerbyol
    Set-AzMarketplaceTerms -Publisher citrix -Product netscalervpx-131 -Name netscalerbyol -Terms $terms -Accept
    '''

  }
}
