### Start job
```powershell
$Token = az account get-access-token --query accessToken --output tsv
$headers = @{
    "Authorization" = "Bearer $Token"
    "Content-type" = "application/json"
}
$Url = "https://management.azure.com/subscriptions/xyz/resourceGroups/rg-sql-czr-dev-01/providers/Microsoft.Sql/servers/sql-system-infra-dev-01/jobAgents/sqlja-elastic-job/jobs/JobSelection/start?api-version=2025-01-01"
Invoke-RestMethod -Method POST -URI $URL -Headers $headers
```