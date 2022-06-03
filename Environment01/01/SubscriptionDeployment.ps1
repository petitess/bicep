Clear-Host

Connect-AzAccount
Set-AzContext -Subscription 
Get-AzContext
Get-AzSubscription

Set-Location 'C:\Users\Karol\OneDrive - B3 Consulting Group AB\bicep'

$Timestamp = Get-Date -Format 'yyyy-MM-dd_HHmmss'

New-AzSubscriptionDeployment -TemplateFile main.bicep -TemplateParameterFile param.json -Location "swedencentral" -Name MyDeployment$Timestamp | select DeploymentName, Location, ProvisioningState, Timestamp, Mode




