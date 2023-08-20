targetScope = 'resourceGroup'

param name string
param location string
param idId string
param kvName string
param virtualMachines array

var tags = resourceGroup().tags
var vm = [for vm in virtualMachines: {
  name: vm.name
}]

resource script 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: name
  location: location
  tags: tags
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${idId}': {}
    }
  }
  properties: {
    azPowerShellVersion: '9.7'
    retentionInterval:  'PT1H'
    timeout: 'PT10M'
    cleanupPreference: 'Always'
    //scriptContent: loadTextContent('secret.ps1')
    scriptContent: '''
    #!/usr/bin/env pwsh

    Connect-AzAccount -Identity

    $VirtualMachines = $env:VirtualMachines | ConvertFrom-Json -AsHashtable
    foreach ($Vm in $VirtualMachines) {
    $GetSecretPass = Get-AzKeyVaultSecret -VaultName $env:KeyVault -Name $Vm.name
    if ($null -eq $GetSecretPass) {
        $Bytes = New-Object Byte[] 24
        ([System.Security.Cryptography.RandomNumberGenerator]::Create()).GetBytes($Bytes)
        $Secret = [System.Convert]::ToBase64String($Bytes)
        $Secret = ConvertTo-SecureString $Secret -AsPlainText -Force
        Set-AzKeyVaultSecret -VaultName $env:KeyVault -Name $Vm.name -SecretValue $Secret
    }
}
    '''
    environmentVariables: [
      {
        name: 'KeyVault'
        value: kvName
      }
      {
        name: 'VirtualMachines'
        value: string(vm)
      }
    ] 
  }
}
