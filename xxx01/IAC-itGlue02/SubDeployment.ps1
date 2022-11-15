﻿Clear-Host

Connect-AzAccount -Tenant 
Set-AzContext -Subscription  "sub-b3care-prod-01"
Get-AzContext
Get-AzSubscription

Set-Location 'C:\Users\$env:username'

Test-AzSubscriptionDeployment -TemplateFile main.bicep -TemplateParameterFile param.json -Location "swedencentral"
New-AzSubscriptionDeployment -TemplateFile main.bicep -TemplateParameterFile param.json -Location "swedencentral" -Name Deploy$(Get-Date -Format 'yyyy-MM-dd') | Select-Object DeploymentName, Location, ProvisioningState, Timestamp, Mode
 