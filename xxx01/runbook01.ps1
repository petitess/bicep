#!/usr/bin/env pwsh
Connect-AzAccount -Identity

#Runbook content:
New-Item -ItemType "directory" -Name script -Path ..\ 
New-Item -ItemType File -Name script.ps1 -Path ..\script -Value @'
$VirtualMachines = Get-AzVM | Where-Object {$_.name -like "vmctxprod*"}

foreach ($Vm in $VirtualMachines) {

$backupcontainer = Get-AzRecoveryServicesBackupContainer `
    -ContainerType "AzureVM" `
    -FriendlyName "$vm.name"
    
$item = Get-AzRecoveryServicesBackupItem `
    -Container $backupcontainer `
    -WorkloadType "AzureVM"

Backup-AzRecoveryServicesBackupItem -Item $item

}
'@

Import-AzAutomationRunbook -Name $env:runbookname -ResourceGroupName $env:rgname -AutomationAccountName $env:aaname -Type PowerShell -Published -Path ..\script\script.ps1
