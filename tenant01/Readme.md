## Azure landing zone

[Configure Azure permissions for ARM tenant deployments](https://github.com/Azure/Enterprise-Scale/wiki/ALZ-Setup-azure)
### For a user:
- Azure Active Directory > Properties > Access management for Azure resources > Yes

- Powershell:

```powershell
$user = Get-AzADUser -UserPrincipalName ""
New-AzRoleAssignment -Scope '/' -RoleDefinitionName 'Owner' -ObjectId $user.Id
Get-AzRoleAssignment -ObjectId $user.Id -Scope "/"
Remove-AzRoleAssignment -Scope '/' -RoleDefinitionName 'Owner' -ObjectId $user.Id
```

- Now you should be able to make deployment in tenant:

```powershell
New-AzTenantDeployment -TemplateFile .\main.bicep -Location "swedencentral" -Name DeployTenant$(Get-Date -Format 'yyyy-MM-dd')
```
### For a service principal:
- Azure Active Directory > Properties > Access management for Azure resources > Yes

- Powershell:

```powershell
$app = Get-AzADServicePrincipal -DisplayName "xxx-Infrastruktur-sp-governance-01"
New-AzRoleAssignment -Scope '/' -RoleDefinitionName 'Owner' -ObjectId $app.Id
Get-AzRoleAssignment -ObjectId $app.Id -Scope "/"
Remove-AzRoleAssignment -Scope '/' -RoleDefinitionName 'Owner' -ObjectId $app.Id
```
## Content

| Name | Description | 
|--|--|
| alz01 | Cloud Adoption Framework policy 
| deploymentscript01 | Create Azure AD groups with managed identity
| deploymentscript02 | Assign roles to Azure AD groups in subscription
| governance01 | Management Grp + Azure AD Grp + Policy
| policy01 | Allowed Resource Types and Allowed VM Size SKUs
| policy02 | Assign build-in and custom policy definitions
| policy03 |Assign Policy Set Definitions
