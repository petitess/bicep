param name string
param location string
param tags object = union(resourceGroup().tags, { Script: 'Privileged Identity Management' })

var policy = {
  properties: {
    rules: [
      {
        isExpirationRequired: false
        maximumDuration: 'P365D'
        id: 'Expiration_Admin_Eligibility'
        ruleType: 'RoleManagementPolicyExpirationRule'
        target: {
          caller: 'Admin'
          operations: [
            'All'
          ]
          level: 'Eligibility'
        }
      }
      {
        notificationType: 'Email'
        recipientType: 'Admin'
        isDefaultRecipientsEnabled: false
        notificationLevel: 'All'
        id: 'Notification_Admin_Admin_Eligibility'
        ruleType: 'RoleManagementPolicyNotificationRule'
        target: {
          caller: 'Admin'
          operations: [
            'All'
          ]
          level: 'Eligibility'
        }
      }
      {
        notificationType: 'Email'
        recipientType: 'Requestor'
        isDefaultRecipientsEnabled: false
        notificationLevel: 'All'
        id: 'Notification_Requestor_Admin_Eligibility'
        ruleType: 'RoleManagementPolicyNotificationRule'
        target: {
          caller: 'Admin'
          operations: [
            'All'
          ]
          level: 'Eligibility'
        }
      }
      {
        notificationType: 'Email'
        recipientType: 'Approver'
        isDefaultRecipientsEnabled: false
        notificationLevel: 'All'
        id: 'Notification_Approver_Admin_Eligibility'
        ruleType: 'RoleManagementPolicyNotificationRule'
        target: {
          caller: 'Admin'
          operations: [
            'All'
          ]
          level: 'Eligibility'
        }
      }
      {
        enabledRules: []
        id: 'Enablement_Admin_Eligibility'
        ruleType: 'RoleManagementPolicyEnablementRule'
        target: {
          caller: 'Admin'
          operations: [
            'All'
          ]
          level: 'Eligibility'
        }
      }
      {
        isExpirationRequired: true
        maximumDuration: 'PT9H'
        id: 'Expiration_Admin_Assignment'
        ruleType: 'RoleManagementPolicyExpirationRule'
        target: {
          caller: 'Admin'
          operations: [
            'All'
          ]
          level: 'Assignment'
        }
      }
      {
        enabledRules: [
          'MultiFactorAuthentication'
        ]
        id: 'Enablement_Admin_Assignment'
        ruleType: 'RoleManagementPolicyEnablementRule'
        target: {
          caller: 'Admin'
          operations: [
            'All'
          ]
          level: 'Assignment'
        }
      }
      {
        notificationType: 'Email'
        recipientType: 'Admin'
        isDefaultRecipientsEnabled: false
        notificationLevel: 'All'
        id: 'Notification_Admin_Admin_Assignment'
        ruleType: 'RoleManagementPolicyNotificationRule'
        target: {
          caller: 'Admin'
          operations: [
            'All'
          ]
          level: 'Assignment'
        }
      }
      {
        notificationType: 'Email'
        recipientType: 'Requestor'
        isDefaultRecipientsEnabled: false
        notificationLevel: 'All'
        id: 'Notification_Requestor_Admin_Assignment'
        ruleType: 'RoleManagementPolicyNotificationRule'
        target: {
          caller: 'Admin'
          operations: [
            'All'
          ]
          level: 'Assignment'
        }
      }
      {
        notificationType: 'Email'
        recipientType: 'Approver'
        isDefaultRecipientsEnabled: false
        notificationLevel: 'All'
        id: 'Notification_Approver_Admin_Assignment'
        ruleType: 'RoleManagementPolicyNotificationRule'
        target: {
          caller: 'Admin'
          operations: [
            'All'
          ]
          level: 'Assignment'
        }
      }
      {
        isExpirationRequired: false
        maximumDuration: 'PT9H'
        id: 'Expiration_EndUser_Assignment'
        ruleType: 'RoleManagementPolicyExpirationRule'
        target: {
          caller: 'EndUser'
          operations: [
            'All'
          ]
          level: 'Assignment'
        }
      }
      {
        enabledRules: [
          'MultiFactorAuthentication'
        ]
        id: 'Enablement_EndUser_Assignment'
        ruleType: 'RoleManagementPolicyEnablementRule'
        target: {
          caller: 'EndUser'
          operations: [
            'All'
          ]
          level: 'Assignment'
        }
      }
      {
        setting: {
          isApprovalRequired: false
          isApprovalRequiredForExtension: false
          isRequestorJustificationRequired: true
          approvalMode: 'SingleStage'
          approvalStages: [
            {
              approvalStageTimeOutInDays: 3
              isApproverJustificationRequired: true
              escalationTimeInMinutes: 12
              primaryApprovers: []
              isEscalationEnabled: false
            }
          ]
        }
        id: 'Approval_EndUser_Assignment'
        ruleType: 'RoleManagementPolicyApprovalRule'
        target: {
          caller: 'EndUser'
          operations: [
            'All'
          ]
          level: 'Assignment'
        }
      }
      {
        isEnabled: false
        claimValue: ''
        id: 'AuthenticationContext_EndUser_Assignment'
        ruleType: 'RoleManagementPolicyAuthenticationContextRule'
        target: {
          caller: 'EndUser'
          operations: [
            'All'
          ]
          level: 'Assignment'
        }
      }
      {
        notificationType: 'Email'
        recipientType: 'Admin'
        isDefaultRecipientsEnabled: false
        notificationLevel: 'All'
        id: 'Notification_Admin_EndUser_Assignment'
        ruleType: 'RoleManagementPolicyNotificationRule'
        target: {
          caller: 'EndUser'
          operations: [
            'All'
          ]
          level: 'Assignment'
        }
      }
      {
        notificationType: 'Email'
        recipientType: 'Requestor'
        isDefaultRecipientsEnabled: false
        notificationLevel: 'All'
        id: 'Notification_Requestor_EndUser_Assignment'
        ruleType: 'RoleManagementPolicyNotificationRule'
        target: {
          caller: 'EndUser'
          operations: [
            'All'
          ]
          level: 'Assignment'
        }
      }
      {
        notificationType: 'Email'
        recipientType: 'Approver'
        isDefaultRecipientsEnabled: false
        notificationLevel: 'All'
        id: 'Notification_Approver_EndUser_Assignment'
        ruleType: 'RoleManagementPolicyNotificationRule'
        target: {
          caller: 'EndUser'
          operations: [
            'All'
          ]
          level: 'Assignment'
        }
      }
    ]
  }
}

resource id 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'id-${name}'
  location: location
  tags: tags
}

resource scriptPIM 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${id.id}': {}
    }
  }
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '9.6'
    retentionInterval: 'PT1H'
    timeout: 'PT10M'
    cleanupPreference: 'Always'
    scriptContent: loadTextContent('./pim.ps1')
    environmentVariables: [
      {
        name: 'SubName'
        value: subscription().displayName
      }
      {
        name: 'RoleManagementPolicy'
        value: string(policy)
      }
    ]
  }
}

module rbac 'rbac.bicep' = {
  name: 'rbac_id'
  scope: subscription()
  params: {
    principalId: id.properties.principalId
    roles: ['Owner']
  }
}

output Pid string = id.properties.principalId
