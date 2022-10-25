#!/usr/bin/env pwsh
Connect-AzAccount -Identity

$now = Get-Date -UFormat "%R"
$temp = (Get-date).AddDays(1)
$tomorrow = Get-Date $temp -UFormat "%m/%d/%Y "
$today = Get-Date -UFormat "%m/%d/%Y "

$schedules = @(
    [pscustomobject]@{name = $env:schedulename01; runbookname = $env:runbookname01; time = $env:scheduletime01; pre = '09:55' }
    [pscustomobject]@{name = $env:schedulename02; runbookname = $env:runbookname01; time = $env:scheduletime02; pre = '12:55' }
    [pscustomobject]@{name = $env:schedulename03; runbookname = $env:runbookname01; time = $env:scheduletime03; pre = '15:55' }
)

#Runbook content:
New-Item -ItemType "directory" -Name script -Path ..\ 
New-Item -ItemType File -Name script.ps1 -Path ..\script -Value @'
Connect-AzAccount -Identity

$vault = Get-AzRecoveryServicesVault -Name $env:rsvname -ResourceGroupName $env:infrargname
Set-AzRecoveryServicesVaultContext -Vault $vault

$VirtualMachines = Get-AzVM | Where-Object {$_.name -like "vmsqlprod*"}

foreach ($Vm in $VirtualMachines) {
$backupcontainer = Get-AzRecoveryServicesBackupContainer `
    -ContainerType "AzureVM" `
    -FriendlyName $Vm.name
    
$item = Get-AzRecoveryServicesBackupItem `
    -Container $backupcontainer `
    -WorkloadType "AzureVM"
Backup-AzRecoveryServicesBackupItem -Item $item -ExpiryDateTimeUTC (Get-Date).AddDays(15)
}
'@

Import-AzAutomationRunbook `
    -Name $env:runbookname01 `
    -ResourceGroupName $env:infrargname `
    -AutomationAccountName $env:aaname `
    -Type PowerShell `
    -Description "Additional backup for SQL servers. Kept for 15 days" `
    -Published `
    -Path ..\script\script.ps1


#create and connect schedules
foreach ($schedule in $schedules) {
    $sche01 = Get-AzAutomationSchedule -ResourceGroupName $env:infrargname `
        -AutomationAccountName $env:aaname | Where-Object { $_.Name -eq $schedule.name }
    if ($null -eq $sche01) {
        if ($now -ge $schedule.pre) {
            New-AzAutomationSchedule -Name $schedule.name `
                -AutomationAccountName $env:aaname -ResourceGroupName $env:infrargname `
                -StartTime "$($tomorrow)$($schedule.time)" -DayInterval 1 -TimeZone "Europe/Berlin"
        }
        else {
            New-AzAutomationSchedule -Name $schedule.name `
                -AutomationAccountName $env:aaname -ResourceGroupName $env:infrargname `
                -StartTime "$($today)$($schedule.time)" -DayInterval 1 -TimeZone "Europe/Berlin"
        }
    }
    $reg01 = Get-AzAutomationScheduledRunbook `
        -AutomationAccountName $env:aaname `
        -ResourceGroupName $env:infrargname | Where-Object { $_.ScheduleName -eq $schedule.name }
    if ($null -eq $reg01) {
        Register-AzAutomationScheduledRunbook -RunbookName $schedule.runbookname `
            -ScheduleName $schedule.name -AutomationAccountName $env:aaname -ResourceGroupName $env:infrargname
    }
}
