param
(
    [Parameter (Mandatory=$false)]
    [object] $WebhookData
)

Connect-AzAccount -Identity

if($(($WebhookData.RequestBody | ConvertFrom-Json).data.essentials.monitorCondition) -eq "Fired")
{
# Restart-AzWebApp -Name "app-gtm-prod-01" -ResourceGroupName "rg-app-gtm-prod-01"
# Restart-AzWebApp -Name "app-gtm-prod-02" -ResourceGroupName "rg-app-gtm-prod-01"
Write-Output "Restarted: app-gtm-prod-01 & app-gtm-prod-02"
}else {
Write-Output "$(($WebhookData.RequestBody | ConvertFrom-Json).data.essentials.monitorCondition)"
}