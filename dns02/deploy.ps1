Set-Location ~"\Desktop\dns02"
Get-AzContext

New-AzSubscriptionDeployment -Name deploy -TemplateFile .\main.bicep -TemplateParameterFile dev.json -Location swedencentral | Select-Object DeploymentName, ProvisioningState, Timestamp
 