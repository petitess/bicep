Connect-AzAccount
Set-AzContext -Subscription
Get-AzContext
Get-AzSubscription

Set-Location "C:\Users\$env:username"

Test-AzSubscriptionDeployment -TemplateFile main.bicep -TemplateParameterFile param.bicepparam -Location "swedencentral"
New-AzSubscriptionDeployment -TemplateFile main.bicep -TemplateParameterFile param.bicepparam -Location "swedencentral" -Name Deploy$(Get-Date -Format 'yyyy-MM-dd') | Select-Object DeploymentName, Location, ProvisioningState, Timestamp, Mode
##Deployment stacks lets you remove resource during deployment
New-AzSubscriptionDeploymentStack -TemplateFile main.bicep -TemplateParameterFile param.bicepparam -Location "swedencentral" -Name Deploy$(Get-Date -Format 'yyyy-MM-dd') -DenySettingsMode None -Force -Confirm:$false -DeleteAll | Select-Object DeploymentName, Location, ProvisioningState, Timestamp, Mode

