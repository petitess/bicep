Set-Location "C:\Users\KarolSek\Desktop\dns"
Get-AzContext

New-AzSubscriptionDeployment -Name deploy -TemplateFile .\main.bicep -TemplateParameterFile dev.json -Location swedencentral | Select-Object DeploymentName, ProvisioningState, Timestamp
 