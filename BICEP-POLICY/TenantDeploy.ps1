Clear-Host
Get-AzPolicyAssignment
Get-AzContext

set-location C:\Users\SEK\Desktop\03param-file-automation-account\policy

New-AzSubscriptionDeployment -Location swedencentral -Name TenantDeploy -TemplateFile mainpolicy.bicep 

#Allowed resource types
Get-AzPolicyDefinition -Name a08ec900-254a-4555-9bf5-e42af04b5c5c

Get-AzPolicySetDefinition