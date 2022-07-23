Set-Location ~"\Desktop"
Get-AzContext 
Set-AzContext -Subscription 

New-AzSubscriptionDeployment -Name deploy -TemplateFile .\main.bicep -TemplateParameterFile param.json -Location swedencentral | Select-Object DeploymentName, ProvisioningState, Timestamp
 
