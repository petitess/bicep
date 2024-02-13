Connect-AzAccount -Identity


$Groups = $env:Groups | ConvertFrom-Json -AsHashtable
foreach ($Group in $Groups) { 
    $GroupName = "grp-rbac-$($Group.name)" 
    if (!(Get-AzADGroup -DisplayName $GroupName)) { 
        $Group = New-AzADGroup -DisplayName $GroupName -MailNickname $GroupName 
        Write-Output "Group created: $GroupName"
    }
}

$Groups = $env:Groups | ConvertFrom-Json -AsHashtable
foreach ($Group in $Groups) { 
    $GroupName = "grp-rbac-$($Group.name)" 
    $ObjectId = (Get-AzADGroup -DisplayName $GroupName).Id
        
    Write-Output "Group exists: $GroupName"
    $DeploymentScriptOutputs[$GroupName] = $ObjectId 
}

$Ids = $env:ManagedId | ConvertFrom-Json -AsHashtable
foreach ($Id in $Ids) { 
    $AppGrpId = (Get-AzADGroup -DisplayName $Id.groupName).Id
    if ((Get-AzADGroupMember -GroupObjectId $AppGrpId).Id -notcontains $Id.objectId) {
        Write-Output "Adding $($Group.name) to $($SubGrpName)"
        Add-AzADGroupMember -TargetGroupObjectId $AppGrpId -MemberObjectId $Id.objectId
        $DeploymentScriptOutputs[$Id.name] = "added to $($Id.groupName)"
    }
}




