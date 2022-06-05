targetScope = 'resourceGroup'

param name string
param location string
param idName string
param kvName string

var tags = resourceGroup().tags

resource id 'Microsoft.ManagedIdentity/userAssignedIdentities@2021-09-30-preview' existing = {
  name: idName
}

resource script 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: name
  location: location
  tags: tags
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${id.id}' :{}
    }
  }
  properties: {
    azPowerShellVersion: '5.0'
    retentionInterval:  'PT1H'
    scriptContent: '''
    $SecretUser = "adminUsernamexxx"

    Connect-AzAccount -Identity
    
    $GetSecretUser = Get-AzKeyVaultSecret -VaultName $env:KeyVault -Name $SecretUser 
    
    if ($null -eq $GetSecretUser) {
        $user = ConvertTo-SecureString "azadmin" -AsPlainText -Force
        Set-AzKeyVaultSecret -VaultName $env:KeyVault -Name $SecretUser -SecretValue $user
    }
    '''   
    environmentVariables: [
      {
        name: 'KeyVault'
        value: kvName
      }
    ] 
  }
}
