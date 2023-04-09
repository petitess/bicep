Clear-Host

Connect-AzAccount -Tenant 
Set-AzContext -Subscription
Get-AzContext
Get-AzSubscription

Set-Location C:\Users\$env:username

Test-AzTenantDeployment -TemplateFile main.bicep -TemplateParameterFile param.json -Location "swedencentral"
New-AzTenantDeployment -TemplateFile main.bicep -TemplateParameterFile param.json -Location "swedencentral" -Name DeployTenant$(Get-Date -Format 'yyyy-MM-dd') | Select-Object DeploymentName, Location, ProvisioningState, Timestamp, Mode, Outputs

#######
Connect-AzAccount

$user = Get-AzADUser -UserPrincipalName "user@xxx.onmicrosoft.com"

New-AzRoleAssignment -Scope '/' -RoleDefinitionName 'Owner' -ObjectId $user.Id

Get-AzRoleAssignment -ObjectId $user.Id -Scope "/"

Remove-AzRoleAssignment -Scope '/' -RoleDefinitionName 'Owner' -ObjectId $user.Id
