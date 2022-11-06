Clear-Host

Connect-AzAccount
Set-AzContext -Subscription 
Get-AzContext
Get-AzSubscription

Set-Location 'C:\Users\$env:username'

Test-AzSubscriptionDeployment -TemplateFile main.bicep -TemplateParameterFile param.json -Location "swedencentral"
New-AzSubscriptionDeployment -TemplateFile main.bicep -TemplateParameterFile param.json -Location "swedencentral" -Name Deploy$(Get-Date -Format 'yyyy-MM-dd') | Select-Object DeploymentName, Location, ProvisioningState, Timestamp, Mode

Set-AzVm -ResourceGroupName "rg-vmimage01" -Name "vmimage01" -Generalized

Set-AzVm -ResourceGroupName "rg-vmimage01" -Name "vmimage01" -Redeploy

(Get-AzVM -ResourceGroupName "rg-vmimage01" -Name "vmimage01" -Status).Statuses[0].DisplayStatus

Get-AzResourceGroup -Name rg-vmimage01 | Remove-AzResourceGroup -Confirm:$false