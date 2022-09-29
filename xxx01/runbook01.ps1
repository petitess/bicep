#!/usr/bin/env pwsh
Connect-AzAccount -Identity

#Runbook content:
New-Item -ItemType "directory" -Name script -Path ..\ 
New-Item -ItemType File -Name script.ps1 -Path ..\script -Value @'
$vault = Get-AzRecoveryServicesVault -Name rsv-infra-prod-01 -ResourceGroupName rg-infra-prod-sc-01
Set-AzRecoveryServicesVaultContext -Vault $vault
$VirtualMachines = Get-AzVM | Where-Object {$_.name -like "vmdcprod*"}
foreach ($Vm in $VirtualMachines) {
$backupcontainer = Get-AzRecoveryServicesBackupContainer `
    -ContainerType "AzureVM" `
    -FriendlyName $Vm.name
    
$item = Get-AzRecoveryServicesBackupItem `
    -Container $backupcontainer `
    -WorkloadType "AzureVM"
Backup-AzRecoveryServicesBackupItem -Item $item -ExpiryDateTimeUTC (Get-Date).AddDays(30)
}
'@

Import-AzAutomationRunbook -Name $env:runbookname -ResourceGroupName $env:rgname -AutomationAccountName $env:aaname -Type PowerShell -Published -Path ..\script\script.ps1
