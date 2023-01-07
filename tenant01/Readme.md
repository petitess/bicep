## Azure landing zone

[Configure Azure permissions for ARM tenant deployments](https://github.com/Azure/Enterprise-Scale/wiki/ALZ-Setup-azure)

- Azure Active Directory > Properties > Access management for Azure resources > Yes

- Powershell:

```powershell
$user = Get-AzADUser -UserPrincipalName ""
New-AzRoleAssignment -Scope '/' -RoleDefinitionName 'Owner' -ObjectId $user.Id
```

- Now you should be able to make deployment in tenant:

```powershell
New-AzTenantDeployment -TemplateFile .\main.bicep -Location "swedencentral" -Name DeployTenant$(Get-Date -Format 'yyyy-MM-dd')
```

## Content

| Name | Description | 
|--|--|
| alz01 | Cloud Adoption Framework policy 
