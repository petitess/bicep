Clear-Host

Disconnect-AzAccount
Connect-AzAccount
Set-AzContext -Subscription "sub-test-01"
Get-AzContext
Get-AzSubscription

Set-Location "C:\Users\$env:username"

Test-AzSubscriptionDeployment -TemplateFile main.bicep -TemplateParameterFile param.bicepparam -Location "swedencentral"
New-AzSubscriptionDeployment -TemplateFile main.bicep -TemplateParameterFile param.bicepparam -Location "swedencentral" -Name Deploy$(Get-Date -Format 'yyyy-MM-dd') | Select-Object DeploymentName, Location, ProvisioningState, Timestamp, Mode

Get-AzVMImage -Location 'swedencentral' -PublisherName 'microsoftwindowsserver' -Offer 'windowsserver' -Skus '2022-datacenter-azure-edition-hotpatch'
Get-AzVMImageOffer -Location 'swedencentral' -PublisherName 'microsoftwindowsserver'
Get-AzVMImagePublisher -Location 'swedencentral'
Get-AzVMImageSku -Location 'swedencentral' -PublisherName 'microsoftwindowsserver' -Offer 'windowsserver'
