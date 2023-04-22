Connect-AzAccount -Identity

$Roles = @( 
    'Reader'
    'Contributor' 
    'Owner' ) 
    
$Scope = $env:SubId
$Environment = $env:EnvName

foreach ($Role in $Roles) { 
    $GroupName = "grp-rbac-comp-$Role" 
    if (!(Get-AzADGroup -DisplayName $GroupName)) { 
        $Group = New-AzADGroup -DisplayName $GroupName -MailNickname $GroupName 
        Write-Output "Group created: $GroupName" 
        if ($Environment -ne 'Test') {
            while (!(Get-AzRoleAssignment -Scope "/subscriptions/$Scope" -ObjectId $Group.Id -RoleDefinitionName $Role)) {
                try {
                    New-AzRoleAssignment -Scope "/subscriptions/$Scope" -ObjectId $Group.Id -RoleDefinitionName $Role -ObjectType Group 2> $null
                }
                catch {}
            }
        }
        else {
            if ($Role -eq 'Reader') {
                while (!(Get-AzRoleAssignment -Scope "/subscriptions/$Scope" -ObjectId $Group.Id -RoleDefinitionName $Role)) {
                    try {
                        New-AzRoleAssignment -Scope "/subscriptions/$Scope" -ObjectId $Group.Id -RoleDefinitionName $Role -ObjectType Group 2> $null
                    }
                    catch {}
                }
            }
        }
    }
}