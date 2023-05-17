#!/usr/bin/env pwsh

$ErrorActionPreference = 'Stop'

Connect-AzAccount -Identity

$SubId = (Get-AzSubscription -SubscriptionName $env:SubName).Id
$Scope = "/subscriptions/$SubId"

$Roles = @( 
    'Contributor' 
    'Owner' ) 

foreach ($Role in $Roles) {
    $RoleId = (Get-AzRoleDefinition -Name $Role).id
    $RoleResourceId = "$Scope/providers/Microsoft.Authorization/roleDefinitions/$RoleId"

    $GroupName = "grp-rbac-$env:SubName-$Role"
    $GroupId = (Get-AzADGroup -DisplayName $GroupName).Id

    if (!$GroupId) {
        throw "Group '$GroupName' not found."
    }

    $Method = 'GET'
    $Path = "$Scope/providers/Microsoft.Authorization/roleManagementPolicies?api-version=2020-10-01-preview&`$filter=roleDefinitionId%20eq%20'$RoleResourceId'"
    $Response = Invoke-AzRestMethod -Method $Method -Path $Path

    if ($Response.StatusCode -ne 200) {
        throw $Response.Content
    }

    $Response = ($Response.Content | ConvertFrom-Json -Depth 100).value

    $RoleManagementPolicyId = $Response.id | Split-Path -Leaf

    $Method = 'PATCH'
    $Path = "$Scope/providers/Microsoft.Authorization/roleManagementPolicies/${RoleManagementPolicyId}?api-version=2020-10-01-preview"
    $Body = $env:RoleManagementPolicy
    $Response = Invoke-AzRestMethod -Method $Method -Path $Path -Payload $Body

    if ($Response.StatusCode -ne 200) {
        throw $Response.Content
    }

    $Method = 'GET'
    $Path = "$Scope/providers/Microsoft.Authorization/roleEligibilityScheduleInstances?api-version=2020-10-01-preview&`$filter=roleDefinitionId%20eq%20'$RoleResourceId'%20and%20principalId%20eq%20'$GroupId'"
    $Response = Invoke-AzRestMethod -Method $Method -Path $Path

    if ($Response.StatusCode -ne 200) {
        throw $Response.Content
    }

    $Response = ($Response.Content | ConvertFrom-Json -Depth 100).value

    if ($Response[-1].properties.status -ne 'Provisioned') {
        $Method = 'PUT'
        $Path = "$Scope/providers/Microsoft.Authorization/roleEligibilityScheduleRequests/$(New-Guid)?api-version=2020-10-01-preview"
        $Body = @{properties = @{roleDefinitionId = "$RoleResourceId"; principalId = $GroupId; requestType = 'AdminAssign'; scheduleInfo = @{expiration = @{type = 'NoExpiration' } } } } | ConvertTo-Json -Depth 100
        $Response = Invoke-AzRestMethod -Method $Method -Path $Path -Payload $Body

        if ($Response.StatusCode -ne 201) {
            throw $Response.Content
        }
    }
}
