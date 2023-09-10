Clear-Host

Connect-AzAccount
Set-AzContext -Subscription
Get-AzContext
Get-AzSubscription

Set-Location "C:\Users\$env:username"

Test-AzTenantDeployment -TemplateFile main.bicep -TemplateParameterFile param.bicepparam -Location "swedencentral"
New-AzTenantDeployment -TemplateFile main.bicep -TemplateParameterFile param.bicepparam -Location "swedencentral" -Name "tenant-deploy" | Select-Object DeploymentName, Location, ProvisioningState, Timestamp, Mode

az deployment tenant what-if --name "tenant-deploy" --location swedencentral --template-file main.bicep --parameters param.bicepparam
az deployment tenant create --name "tenant-deploy" --location swedencentral --template-file main.bicep --parameters param.bicepparam

#Get billing info
$billingAccounts = Get-AzBillingAccount
$billingProfile = Get-AzBillingProfile -BillingAccountName ($billingAccounts).Name
$invoiceSections = Get-AzInvoiceSection -BillingAccountName (Get-AzBillingAccount).Name -BillingProfileName ($billingProfile).Name

#Role assigment on tenant scope
$user = Get-AzADUser -UserPrincipalName ""
Get-AzRoleAssignment -ObjectId $user.Id -Scope "/"
New-AzRoleAssignment -Scope '/' -RoleDefinitionName 'Owner' -ObjectId $user.Id


Get-AzTenantDeployment | Where-Object {$_.ProvisioningState -eq "Running"}
Stop-AzTenantDeployment -Name "new-subscriptions"
Stop-AzTenantDeployment -Name "tenant-deploy"
#https://learn.microsoft.com/en-us/azure/cost-management-billing/manage/create-subscriptions-deploy-resources

#Permissions
#Key Vault Admin (if you want to save secrets)
#Owner at tenant scope
#Application Admin
#Billing account contributor (in Billing subscriptions)
