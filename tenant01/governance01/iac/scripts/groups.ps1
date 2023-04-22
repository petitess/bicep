$groups = $env:AdGroups | ConvertFrom-Json

foreach ($group in $groups.prefix) {
    if (!(Get-AzADGroup -DisplayNameStartsWith $group)) {
        New-AzADGroup -DisplayName "$group-prod-01-reader" -MailNickname "$group-prod-01-reader"
        New-AzADGroup -DisplayName "$group-prod-01-contributor" -MailNickname "$group-prod-01-contributor"
        New-AzADGroup -DisplayName "$group-prod-01-owner" -MailNickname "$group-prod-01-owner"
        Write-Output "Groups created"
    }
}