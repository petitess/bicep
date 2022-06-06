Clear-Host

Connect-AzAccount
Set-AzContext -Subscription 
Get-AzContext
Get-AzSubscription

Set-Location 'C:\Users\Karol'


New-AzSubscriptionDeployment -TemplateFile main.bicep -TemplateParameterFile param.json -Location "swedencentral" -Name Deploy$(Get-Date -Format 'yyyy-MM-dd_HHmmss') | select DeploymentName, Location, ProvisioningState, Timestamp, Mode




