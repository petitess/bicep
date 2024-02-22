Clear-Host

Connect-AzAccount
Set-AzContext -Subscription "sub-test-01"
Get-AzContext
Get-AzSubscription

Set-Location "C:\Users\$env:username"

Test-AzSubscriptionDeployment -TemplateFile main.bicep -TemplateParameterFile param.bicepparam -Location "swedencentral"

$ExistingVMs = (Get-AzVM).Name
New-AzSubscriptionDeployment -TemplateFile main.bicep `
-TemplateParameterFile param.bicepparam `
-Location "swedencentral" `
-Name Deploy$(Get-Date -Format 'yyyy-MM-dd') `
-existingVMs $ExistingVMs | Select-Object DeploymentName, Location, ProvisioningState, Timestamp, Mode