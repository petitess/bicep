Clear-Host

Connect-AzAccount -Tenant
Set-AzContext -Subscription
Get-AzContext
Get-AzSubscription

Set-Location 'C:\Users\$env:username'

Test-AzSubscriptionDeployment -TemplateFile main.bicep -TemplateParameterFile param.json -Location "swedencentral"
New-AzSubscriptionDeployment -TemplateFile main.bicep -TemplateParameterFile param.json -Location "swedencentral" -Name Deploy$(Get-Date -Format 'yyyy-MM-dd') | Select-Object DeploymentName, Location, ProvisioningState, Timestamp, Mode

Remove-AzAutoscaleSetting -ResourceGroupName "rg-app-gtm-test-01" -Name "app-gtm-test-02-autoscale01"