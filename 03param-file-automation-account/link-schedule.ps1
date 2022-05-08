#!/usr/bin/env pwsh

$SecretUser = "adminUsername"

Connect-AzAccount -Identity

$schedule = Get-AzAutomationScheduledRunbook -ResourceGroupName rg-aa-prod-sc-01 -AutomationAccountName aa-infra-prod-comp-01


$automationAccountName = "aa-infra-prod-comp-01"
$runbookName = "Powershell01"
$scheduleName = "PS-schedule"
$ResourceGroupName = "rg-aa-prod-sc-01"

$params = @{"FirstName"="Joe";"LastName"="Smith";"RepeatCount"=2;"Show"=$true}


if ($schedule -eq $null) {
           Register-AzAutomationScheduledRunbook -AutomationAccountName $automationAccountName `
-Name $runbookName -ScheduleName $scheduleName `
-ResourceGroupName $ResourceGroupName
    
    } 

    
