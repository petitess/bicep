targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param idId string
param idName string
param kvName string
param param object
param aaname string
param aargname string
param rsvname string

output rs string = rsvname

resource script01 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
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

resource script02 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'BackupSqlVM'
  location: location
  kind: 'AzurePowerShell'
  tags: {
    Application: 'Automation Account - Runbook'
    Service: aaname
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${idId}': {}
    }
  }
  properties: {
    azPowerShellVersion: '5.0'
    retentionInterval: 'PT1H'
    timeout: 'PT10M'
    cleanupPreference: 'Always'
    environmentVariables: [
      {
        name: 'infrargname'
        value: aargname
      }
      {
        name: 'aaname'
        value: aaname
      }
      {
        name: 'runbookname01'
        value: param.runbooks.sqlbackup.runbookname
      }
      {
        name: 'rsvname'
        value: rsvname
      }
      {
        name: 'schedulename01'
        value: 'sch-BackupSqlVm01'
      }
      {
        name: 'schedulename02'
        value: 'sch-BackupSqlVm02'
      }
      {
        name: 'schedulename03'
        value: 'sch-BackupSqlVm03'
      }
      {
        name: 'scheduletime01'
        value: param.runbooks.sqlbackup.startTime01
      }
      {
        name: 'scheduletime02'
        value: param.runbooks.sqlbackup.startTime02
      }
      {
        name: 'scheduletime03'
        value: param.runbooks.sqlbackup.startTime03
      }
    ]
    scriptContent: loadTextContent('../scripts/run-BackupSqlVM01.ps1')
  }
}

resource script03 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'StopStartVM'
  location: location
  kind: 'AzurePowerShell'
  tags: {
    Application: 'Automation Account - Runbook'
    Service: aaname
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${idId}': {}
    }
  }
  properties: {
    azPowerShellVersion: '5.0'
    retentionInterval: 'PT1H'
    timeout: 'PT10M'
    cleanupPreference: 'Always'
    environmentVariables: [
      {
        name: 'infrargname'
        value: aargname
      }
      {
        name: 'aaname'
        value: aaname
      }
      {
        name: 'runbookname01'
        value: param.runbooks.stopstartvm.runbookname01
      }
      {
        name: 'runbookname02'
        value: param.runbooks.stopstartvm.runbookname02
      }
      {
        name: 'runbookname03'
        value: param.runbooks.stopstartvm.runbookname03
      }
      {
        name: 'runbookname04'
        value: param.runbooks.stopstartvm.runbookname04
      }
      {
        name: 'schedulename01'
        value: replace(param.runbooks.stopstartvm.runbookname01, 'run', 'sch')
      }
      {
        name: 'schedulename02'
        value: replace(param.runbooks.stopstartvm.runbookname02, 'run', 'sch')
      }
      {
        name: 'schedulename03'
        value: replace(param.runbooks.stopstartvm.runbookname03, 'run', 'sch')
      }
      {
        name: 'schedulename04'
        value: replace(param.runbooks.stopstartvm.runbookname04, 'run', 'sch')
      }
      {
        name: 'stopvmtime'
        value: param.runbooks.stopstartvm.stopvmtime
      }
      {
        name: 'startvmtime'
        value: param.runbooks.stopstartvm.startvmtime
      }
    ]
    scriptContent: loadTextContent('../scripts/run-StopStartVM01.ps1')
  }
}

output id string = script01.id
output consecret string = script01.properties.outputs.ConnectionName01
