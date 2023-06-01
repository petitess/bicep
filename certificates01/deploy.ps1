Get-AzContext

Test-AzSubscriptionDeployment -Name deploy -TemplateFile .\main.bicep -TemplateParameterFile dev.json -Location swedencentral
New-AzSubscriptionDeployment -Name deploy -TemplateFile .\main.bicep -TemplateParameterFile dev.json -Location swedencentral | Select-Object DeploymentName, ProvisioningState, Timestamp
 