Clear-Host

Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
Connect-AzAccount -TenantId e44a6fe3-543e-47c1-a8e6-0ab2841227c8
Set-AzContext -Subscription 0dcc13b7-1a10-483e-xxxx
Connect-AzAccount -TenantId e44a6fe3-543e-47c1-a8e6-0ab2841227c8
Get-AzContext
Get-AzSubscription

Set-Location C:\Users\SEK\Desktop\03param-file-automation-account

New-AzSubscriptionDeployment -TemplateFile main.bicep -Location "swedencentral" -Name MyDeployment -TemplateParameterFile prod.parameters.json | Select-Object DeploymentName, Location, ProvisioningState, Timestamp, Mode

Get-AzSubscriptionDeployment -name MyDeployment | select DeploymentName, Location, ProvisioningState, Timestamp, Mode

Get-AzResourceGroupDeployment -ResourceGroupName rg-aa-prod-sc-01

Clear-Host
Get-AzResourceGroup

Get-TimeZone


Get-AzAutomationJob -ResourceGroupName rg-aa-prod-sc-01 -AutomationAccountName aa-infra-prod-comp-01
Get-AzAutomationScheduledRunbook -ResourceGroupName rg-aa-prod-sc-01 -AutomationAccountName aa-infra-prod-comp-01


Get-AzResourceGroup -Name * | Remove-AzResourceGroup -Force
networkwatcher

###########
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install


Get-AzAutomationSchedule -ResourceGroupName rg-aa-prod-sc-01 -AutomationAccountName aa-infra-prod-comp-01

Get-AzAutomationJob -ResourceGroupName rg-aa-prod-sc-01 -AutomationAccountName aa-infra-prod-comp-01

Get-AzAutomationJob -ResourceGroupName rg-aa-prod-sc-01 -AutomationAccountName aa-infra-prod-comp-01

get-AzAutomationScheduledRunbook -ResourceGroupName rg-aa-prod-sc-01 -AutomationAccountName aa-infra-prod-comp-01
