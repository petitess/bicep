#!/usr/bin/env pwsh
Connect-AzAccount -Identity

$now = Get-Date -UFormat "%R"
$temp = (Get-date).AddDays(1)
$tomorrow = Get-Date $temp -UFormat "%m/%d/%Y "
$today = Get-Date -UFormat "%m/%d/%Y "
$number = 1
$schedules = @(
    [pscustomobject]@{name = 'sch-StopVm01'; runbookname = 'run-StopVm01'; time = '20:00'; pre = '19:55' }
    [pscustomobject]@{name = 'sch-StartVm01'; runbookname = 'run-StartVm01'; time = '6:00'; pre = '05:55' }
    [pscustomobject]@{name = 'sch-StopVm02'; runbookname = 'run-StopVm02'; time = '20:00'; pre = '19:55' }
    [pscustomobject]@{name = 'sch-StartVm02'; runbookname = 'run-StartVm02'; time = '6:00'; pre = '05:55' }
)

#create first runbook
New-Item -ItemType "directory" -Name script -Path ..\ 
New-Item -ItemType File -Name script1.ps1 -Path ..\script -Value @'
Connect-AzAccount -Identity

$TagKey = "AutoShutdown"
$TagValues = "GroupA"

$VMs = Get-AzVM | Where-Object {$_.Tags.Keys -eq $TagKey -and $_.Tags.Values -eq $TagValues}

ForEach ($VM in $VMs) {
Stop-AzVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.Name -Force
}
'@
#create second runbook
New-Item -ItemType File -Name script2.ps1 -Path ..\script -Value @'
Connect-AzAccount -Identity

$TagKey = "AutoShutdown"
$TagValues = "GroupA"

$VMs = Get-AzVM | Where-Object {$_.Tags.Keys -eq $TagKey -and $_.Tags.Values -eq $TagValues}

ForEach ($VM in $VMs) {
Start-AzVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.Name
}
'@
#create third runbook
New-Item -ItemType File -Name script3.ps1 -Path ..\script -Value @'
Connect-AzAccount -Identity

$TagKey = "AutoShutdown"
$TagValues = "GroupB"

$VMs = Get-AzVM | Where-Object {$_.Tags.Keys -eq $TagKey -and $_.Tags.Values -eq $TagValues}

ForEach ($VM in $VMs) {
Stop-AzVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.Name -Force
}
'@
#create forth runbook
New-Item -ItemType File -Name script4.ps1 -Path ..\script -Value @'
Connect-AzAccount -Identity

$TagKey = "AutoShutdown"
$TagValues = "GroupB"

$VMs = Get-AzVM | Where-Object {$_.Tags.Keys -eq $TagKey -and $_.Tags.Values -eq $TagValues}

ForEach ($VM in $VMs) {
Start-AzVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.Name
}
'@

foreach ($schedule in $schedules) {
    Import-AzAutomationRunbook `
        -Name $schedule.runbookname `
        -ResourceGroupName $env:infrargname `
        -AutomationAccountName $env:aaname `
        -Type PowerShell `
        -Published `
        -Path ..\script\script$($number+++'').ps1 `
        -Force
}

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