if ($false) {
    ##Login to Azure to get access token
    Connect-AzAccount
    Disconnect-AzAccount
    Set-AzContext "sub-test-01"
}

$DcrImmutableId = 'dcr-9ced9ef8eb2348bfbeb0f5e2e30065ea'
$DceIngestionUrl = 'https://dce-dev-01-1y9g.swedencentral-1.ingest.monitor.azure.com'
$MyTableName = 'mycommand'
$URL = "$DceIngestionUrl/dataCollectionRules/$DcrImmutableId/streams/Custom-$($MyTableName)_CL?api-version=2023-01-01"
$headers = @{
    "Authorization" = "Bearer $((Get-AzAccessToken -ResourceUrl "https://monitor.azure.com").Token)"
    # "Authorization" = "Bearer $(az account get-access-token -o tsv --query accessToken --resource "https://monitor.azure.com")"
    "Content-type"  = "application/json; charset=utf-8"
}
$Body = ConvertTo-Json @(@{
        TimeGenerated = Get-Date -Format "yyyy-MM-dd-HH-mm"
        Location      = "SwedenCentral"
        My_prop       = "hello"
        Dev           = "bio-588"
        RawData       = @{
            dev = "sony-389"
        }
        Subscription  = "booom-123"
    }
    @{
        TimeGenerated = Get-Date -Format "yyyy-MM-dd-HH-mm"
        Location      = "WestEurope"
        My_prop       = "Hi"
        Dev           = "bio-098"
        RawData       = @{
            dev = "bio-456"
        }
        Subscription  = "bio-456"
    })
Invoke-RestMethod -Uri $URL -Method Post -Headers $headers -Body $Body


az account get-access-token -o tsv --query accessToken --resource "https://monitor.azure.com"