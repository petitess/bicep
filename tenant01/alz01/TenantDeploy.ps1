Clear-Host

Connect-AzAccount -TenantId 
Set-AzContext -Subscription 
Get-AzContext
Get-AzSubscription

Set-Location ~

Test-AzTenantDeployment -TemplateFile main.bicep -TemplateParameterFile param.json -Location "swedencentral"
New-AzTenantDeployment -TemplateFile main.bicep -TemplateParameterFile param.json -Location "swedencentral" -Name DeployTenant$(Get-Date -Format 'yyyy-MM-dd') | Select-Object DeploymentName, Location, ProvisioningState, Timestamp, Mode, Outputs
