#install azure cli
#install azure bicep cli
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
Connect-AzAccount
Set-AzContext -Subscription 0dcc13b7-1a10-483e-xxxx
Get-AzContext

Set-Location C:\Users\Karol\Desktop\3vm-1vnet-param_file

New-AzSubscriptionDeployment -TemplateFile main.bicep -Location "swedencentral" -Name MyDeployment -TemplateParameterFile prod.parameters.json

