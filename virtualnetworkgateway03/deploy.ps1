Set-Location ~"\Desktop"
Get-AzContext 
Set-AzContext -Subscription 

Test-AzSubscriptionDeployment -Name deploy -TemplateFile .\main.bicep -TemplateParameterFile param.json -Location swedencentral
New-AzSubscriptio nDeployment -Name Deploy$(Get-Date -Format 'yyyy-MM-dd') -TemplateFile .\main.bicep -TemplateParameterFile param.json -Location swedencentral | Select-Object DeploymentName, ProvisioningState, Timestamp
 
