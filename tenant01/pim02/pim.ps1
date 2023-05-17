#!/usr/bin/env pwsh

$ErrorActionPreference = 'Stop'

Connect-AzAccount -Identity
###GROUP CREATION
$Roles = @( 
    'Reader'
    'Contributor' 
    'Owner' ) 
    
$Scope = (Get-AzSubscription -SubscriptionName $env:SubName).Id 
$Environment = $env:EnvName

foreach ($Role in $Roles) { 
    $GroupName = "grp-rbac-$env:SubName-$Role" 
    if (!(Get-AzADGroup -DisplayName $GroupName)) { 
        $Group = New-AzADGroup -DisplayName $GroupName -MailNickname $GroupName 
        Write-Output "Group created: $GroupName" 
        if ($Environment -ne 'Production') {
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
###PIM ASSIGMENT
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

    $RoleManagementPolicyId = (Get-AzRoleManagementPolicyAssignment -Scope $Scope | Where-Object { $_.RoleDefinitionId -eq $RoleResourceId }).PolicyId | Split-Path -Leaf

    $Rules = @(
        [Microsoft.Azure.PowerShell.Cmdlets.Resources.Authorization.Models.Api20201001Preview.RoleManagementPolicyExpirationRule]@{
            id                   = 'Expiration_Admin_Assignment'
            ruleType             = 'RoleManagementPolicyExpirationRule'
            isExpirationRequired = $true
            maximumDuration      = 'PT9H'
        }
        [Microsoft.Azure.PowerShell.Cmdlets.Resources.Authorization.Models.Api20201001Preview.RoleManagementPolicyExpirationRule]@{
            id                   = 'Expiration_Admin_Eligibility'
            ruleType             = 'RoleManagementPolicyExpirationRule'
            isExpirationRequired = $false
        } 
        [Microsoft.Azure.PowerShell.Cmdlets.Resources.Authorization.Models.Api20201001Preview.RoleManagementPolicyExpirationRule]@{
            id                   = 'Expiration_EndUser_Assignment'
            ruleType             = 'RoleManagementPolicyExpirationRule'
            isExpirationRequired = $true
            maximumDuration      = 'PT9H'
        }
        [Microsoft.Azure.PowerShell.Cmdlets.Resources.Authorization.Models.Api20201001Preview.RoleManagementPolicyEnablementRule]@{
            id          = 'Enablement_Admin_Assignment'
            ruleType    = 'RoleManagementPolicyEnablementRule'
            enabledRule = @('MultiFactorAuthentication')
        }
        [Microsoft.Azure.PowerShell.Cmdlets.Resources.Authorization.Models.Api20201001Preview.RoleManagementPolicyEnablementRule]@{
            id          = 'Enablement_Admin_Eligibility'
            ruleType    = 'RoleManagementPolicyEnablementRule'
            enabledRule = @('MultiFactorAuthentication')
        }
        [Microsoft.Azure.PowerShell.Cmdlets.Resources.Authorization.Models.Api20201001Preview.RoleManagementPolicyEnablementRule]@{
            id          = 'Enablement_EndUser_Assignment'
            ruleType    = 'RoleManagementPolicyEnablementRule'
            enabledRule = @('MultiFactorAuthentication')
        }
        [Microsoft.Azure.PowerShell.Cmdlets.Resources.Authorization.Models.Api20201001Preview.RoleManagementPolicyNotificationRule]@{
            id                          = 'Notification_Admin_Admin_Eligibility'
            ruleType                    = 'RoleManagementPolicyNotificationRule'
            notificationType            = 'Email'
            recipientType               = 'Admin'
            areDefaultRecipientsEnabled = $false
            notificationLevel           = 'None'
        }
        [Microsoft.Azure.PowerShell.Cmdlets.Resources.Authorization.Models.Api20201001Preview.RoleManagementPolicyNotificationRule]@{
            id                          = 'Notification_Requestor_Admin_Eligibility'
            ruleType                    = 'RoleManagementPolicyNotificationRule'
            notificationType            = 'Email'
            recipientType               = 'Requestor'
            areDefaultRecipientsEnabled = $false
            notificationLevel           = 'None'
        }
        [Microsoft.Azure.PowerShell.Cmdlets.Resources.Authorization.Models.Api20201001Preview.RoleManagementPolicyNotificationRule]@{
            id                          = 'Notification_Approver_Admin_Eligibility'
            ruleType                    = 'RoleManagementPolicyNotificationRule'
            notificationType            = 'Email'
            recipientType               = 'Approver'
            areDefaultRecipientsEnabled = $false
            notificationLevel           = 'None'
        }
        [Microsoft.Azure.PowerShell.Cmdlets.Resources.Authorization.Models.Api20201001Preview.RoleManagementPolicyNotificationRule]@{
            id                          = 'Notification_Admin_Admin_Assignment'
            ruleType                    = 'RoleManagementPolicyNotificationRule'
            notificationType            = 'Email'
            recipientType               = 'Admin'
            areDefaultRecipientsEnabled = $false
            notificationLevel           = 'None'
        }
        [Microsoft.Azure.PowerShell.Cmdlets.Resources.Authorization.Models.Api20201001Preview.RoleManagementPolicyNotificationRule]@{
            id                          = 'Notification_Requestor_Admin_Assignment'
            ruleType                    = 'RoleManagementPolicyNotificationRule'
            notificationType            = 'Email'
            recipientType               = 'Requestor'
            areDefaultRecipientsEnabled = $false
            notificationLevel           = 'None'
        }
        [Microsoft.Azure.PowerShell.Cmdlets.Resources.Authorization.Models.Api20201001Preview.RoleManagementPolicyNotificationRule]@{
            id                          = 'Notification_Approver_Admin_Assignment'
            ruleType                    = 'RoleManagementPolicyNotificationRule'
            notificationType            = 'Email'
            recipientType               = 'Approver'
            areDefaultRecipientsEnabled = $false
            notificationLevel           = 'None'
        }
        [Microsoft.Azure.PowerShell.Cmdlets.Resources.Authorization.Models.Api20201001Preview.RoleManagementPolicyNotificationRule]@{
            id                          = 'Notification_Admin_EndUser_Assignment'
            ruleType                    = 'RoleManagementPolicyNotificationRule'
            notificationType            = 'Email'
            recipientType               = 'Admin'
            areDefaultRecipientsEnabled = $false
            notificationLevel           = 'None'
        }
        [Microsoft.Azure.PowerShell.Cmdlets.Resources.Authorization.Models.Api20201001Preview.RoleManagementPolicyNotificationRule]@{
            id                          = 'Notification_Requestor_EndUser_Assignment'
            ruleType                    = 'RoleManagementPolicyNotificationRule'
            notificationType            = 'Email'
            recipientType               = 'Requestor'
            areDefaultRecipientsEnabled = $false
            notificationLevel           = 'None'
        }
        [Microsoft.Azure.PowerShell.Cmdlets.Resources.Authorization.Models.Api20201001Preview.RoleManagementPolicyNotificationRule]@{
            id                          = 'Notification_Approver_EndUser_Assignment'
            ruleType                    = 'RoleManagementPolicyNotificationRule'
            notificationType            = 'Email'
            recipientType               = 'Approver'
            areDefaultRecipientsEnabled = $false
            notificationLevel           = 'None'
        }
        [Microsoft.Azure.PowerShell.Cmdlets.Resources.Authorization.Models.Api20201001Preview.RoleManagementPolicyApprovalRule]@{
            id       = 'Approval_EndUser_Assignment'
            ruleType = 'RoleManagementPolicyApprovalRule'
            setting  = @{
                isApprovalRequired               = $false
                isApprovalRequiredForExtension   = $true
                isRequestorJustificationRequired = $true
                approvalMode                     = "SingleStage"
                approvalStage                    = @(
                    @{
                        approvalStageTimeOutInDays      = 1
                        isApproverJustificationRequired = $true
                        escalationTimeInMinutes         = 0
                        primaryApprovers                = @()
                        isEscalationEnabled             = $false
                    }
                )
            }
        }
        [Microsoft.Azure.PowerShell.Cmdlets.Resources.Authorization.Models.Api20201001Preview.RoleManagementPolicyAuthenticationContextRule]@{
            id        = 'AuthenticationContext_EndUser_Assignment'
            ruleType  = 'RoleManagementPolicyAuthenticationContextRule'
            IsEnabled = $false
        }
    )

    Update-AzRoleManagementPolicy -Scope $Scope -Name $RoleManagementPolicyId -Rule $Rules

    if (!(Get-AzRoleEligibilityScheduleInstance -Scope $Scope | Where-Object { $_.RoleDefinitionId -eq $RoleResourceId -and $_.PrincipalId -eq $GroupId })) {
        New-AzRoleEligibilityScheduleRequest -Scope $Scope -Name (New-Guid) -RoleDefinitionId $RoleResourceId -PrincipalId $GroupId -RequestType 'AdminAssign' -ExpirationType 'NoExpiration'  
    }
}

