#!/usr/bin/env pwsh
Connect-AzAccount -Identity

#Runbook content:
New-Item -ItemType "directory" -Name script -Path ..\ 
New-Item -ItemType File -Name script.ps1 -Path ..\script -Value @'
Connect-AzAccount -Identity

$ErrorActionPreference = 'Stop'
$rgname = 'rg-vmmgmtprod01'
$vmname = 'vmmgmtprod01'
$localmachineScript = 'C:\B3\AdPasswordExpiration.ps1'

Connect-AzAccount -Identity

Out-File -FilePath aa.ps1 -InputObject $localmachineScript

#Note that the -ScriptPath should not point to the remote path(in remote vm), it should point to the local path where you execute the command Invoke-AzureRmVMRunCommand
Invoke-AzVMRunCommand -ResourceGroupName $rgname -Name $vmname -CommandId 'RunPowerShellScript' -ScriptPath aa.ps1

#after execution, you can remove the file
Remove-Item -Path aa.ps1
'@

Import-AzAutomationRunbook `
    -Name $env:runbookname01 `
    -ResourceGroupName $env:infrargname `
    -AutomationAccountName $env:aaname `
    -Tags @{Application = 'AD Password Expiration'} `
    -Type PowerShell `
    -Description "A script to execute a powershell script on vmmgmtprod01 - AdPasswordExpiration.ps1, to check the expiration password date for user accounts. Triggered by Logic App." `
    -Published `
    -Path ..\script\script.ps1 -Force
