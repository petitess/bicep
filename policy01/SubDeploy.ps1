Clear-Host

Connect-AzAccount
Set-AzContext -Subscription
Get-AzContext
Get-AzSubscription

Set-Location ~
Test-AzSubscriptionDeployment -TemplateFile main.bicep -TemplateParameterFile param.json -Location "swedencentral"
New-AzSubscriptionDeployment -TemplateFile main.bicep -TemplateParameterFile param.json -Location "swedencentral" -Name Deploy$(Get-Date -Format 'yyyy-MM-dd') | Select-Object DeploymentName, Location, ProvisioningState, Timestamp, Mode


$rp = ((Get-AzResourceProvider -ProviderNamespace "Microsoft.Compute" -Location "swedencentral").ResourceTypes).ResourceTypeName

foreach ($r in $rp) {
Write-Output "'Microsoft.Compute/$r'"
}