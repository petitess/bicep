targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param idId string
param idName string
param kvName string
param param object

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
   
    $GetSecretPass = Get-AzKeyVaultSecret -VaultName $env:KeyVault -Name $env:SecretName
    if ($null -eq $GetSecretPass) {
        $Bytes = New-Object Byte[] 24
        ([System.Security.Cryptography.RandomNumberGenerator]::Create()).GetBytes($Bytes)
        $Secret = [System.Convert]::ToBase64String($Bytes)
        $Secret = ConvertTo-SecureString $Secret -AsPlainText -Force
        Set-AzKeyVaultSecret -VaultName $env:KeyVault -Name $env:SecretName -SecretValue $Secret
    }
    $DeploymentScriptOutputs["ConnectionName01"] = (Get-AzKeyVaultSecret -VaultName $env:KeyVault -Name $env:SecretName).Name
    '''
    environmentVariables: [
      {
        name: 'KeyVault'
        value: kvName
      }
      {
        name: 'SecretName'
        value: param.con.name
      }
    ]
  }
}

output id string = script.id
output consecret string = script.properties.outputs.ConnectionName01
