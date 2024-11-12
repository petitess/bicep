if ($false) {
    ##Login to Azure to get access token
    Connect-AzAccount
    Disconnect-AzAccount
    Set-AzContext "sub-test-01"
}

$DcrImmutableId = 'dcr-dc4e6fab9a804027be3ec8c14aeeeabb'
$DceIngestionUrl = 'https://dce-dev-01-r95x.swedencentral-1.ingest.monitor.azure.com'
$MyTableName = 'mycommand'
$URL = "$DceIngestionUrl/dataCollectionRules/$DcrImmutableId/streams/Custom-$($MyTableName)_CL?api-version=2023-01-01"
$headers = @{
    "Authorization" = "Bearer $((Get-AzAccessToken -ResourceUrl "https://monitor.azure.com").Token)"
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