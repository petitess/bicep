Clear-Host

Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
Connect-AzAccount -TenantId e44a6fe3-543e-47c1-a8e6-0ab28412
Get-AzContext
Get-AzSubscription

Set-Location C:\Users\SEK\Desktop\03param-file-automation-account

New-AzSubscriptionDeployment -TemplateFile main.bicep -Location "swedencentral" -Name MyDeployment -TemplateParameterFile test.parameters.json | Select-Object DeploymentName, Location, ProvisioningState, Timestamp, Mode


###########
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install

