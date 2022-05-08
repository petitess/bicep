#!/usr/bin/env pwsh

Connect-AzAccount -Identity

$ResourceGroupName = "rg-aa-test-sc-01"
$automationAccountName = "aa-infra-test-comp-01"
$runbookName = "Powershell01"
$scheduleName = "PS-schedule"

$schedule = Get-AzAutomationScheduledRunbook -ResourceGroupName $ResourceGroupName -AutomationAccountName $automationAccountName

if ($null -eq $schedule) {
           Register-AzAutomationScheduledRunbook -AutomationAccountName $automationAccountName `
-Name $runbookName -ScheduleName $scheduleName `
-ResourceGroupName $ResourceGroupName
    
    } 

