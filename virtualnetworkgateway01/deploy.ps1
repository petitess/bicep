Connect-AzAccount
Set-AzContext -Subscription "sub-care-test-01"
Get-AzContext
Get-AzSubscription

Set-Location "C:\Users\$env:username"

Test-AzSubscriptionDeployment -TemplateFile main.bicep -TemplateParameterFile .\parameters\prod.bicepparam -Location "swedencentral"
New-AzSubscriptionDeployment -TemplateFile main.bicep -TemplateParameterFile .\parameters\prod.bicepparam -Location "swedencentral" -Name Deploy$(Get-Date -Format 'yyyy-MM-dd') | Select-Object DeploymentName, Location, ProvisioningState, Timestamp, Mode