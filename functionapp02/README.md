## Invoke Function App
```pwsh
$AppId = "x-169d9abf5dd3"
$AppPass = "xeC0EdAB"
$Tenant = "x-3fc5167644de"
$Scope = "api://func-authorization-test-01/.default"
$FuncUrl = "https://func-win-infra-dev-01.azurewebsites.net/api/Function1"
az login --service-principal -u $AppId -p $AppPass --tenant $Tenant
$Token = az account get-access-token --scope $Scope --query accessToken --output tsv
$headers = @{
    "Authorization" = "Bearer $Token"
    "Content-type"  = "application/json"
}
Invoke-RestMethod -Uri $FuncUrl -Headers $headers -Method Get
```
