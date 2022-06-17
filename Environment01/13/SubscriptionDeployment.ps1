Clear-Host

Connect-AzAccount
Set-AzContext -Subscription 
Get-AzContext
Get-AzSubscription

Set-Location 'C:\Users'


New-AzSubscriptionDeployment -TemplateFile main.bicep -TemplateParameterFile param.json -Location "swedencentral" -Name Deploy$(Get-Date -Format 'yyyy-MM-dd') | select DeploymentName, Location, ProvisioningState, Timestamp, Mode




