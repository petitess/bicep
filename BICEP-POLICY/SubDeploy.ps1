Clear-Host
Get-AzPolicyAssignment
Get-AzContext

set-location C:\Users\SEK\Desktop\03param-file-automation-account\BICEP-POLICY

New-AzSubscriptionDeployment -Location swedencentral -Name PolicyDeploy -TemplateFile Allow_env_sub.bicep

New-AzManagementGroupDeployment -Location swedencentral -Name PolicyDeploy -TemplateFile Allow_env_mgmt.bicep -ManagementGroupId MGMT
