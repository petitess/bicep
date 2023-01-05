#https://github.com/Azure/Enterprise-Scale/wiki/ALZ-Setup-azure

$user = Get-AzADUser -UserPrincipalName ""

New-AzRoleAssignment -Scope '/' -RoleDefinitionName 'Owner' -ObjectId $user.Id
