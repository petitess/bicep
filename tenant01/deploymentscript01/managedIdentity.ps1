#$pathConfig = ".\config.json"
#$jsonConfig = Get-Content $pathConfig | Out-String | ConvertFrom-Json

$TenantID = "xxxxx-543e-47c1-a8e6-xxxxx" #$jsonConfig.tenantID
$subscriptionId = "xxxxx-e3df-4ea1-b956-xxxx" #$jsonConfig.subscriptionId

$managedIdentity = "id-script-governance-prod-sc-01"

$rgName = "rg-governance-prod-sc-01"

Connect-AzAccount -TenantId $TenantID -Subscription $subscriptionId

$userAssignedId = Get-AzUserAssignedIdentity -Name $managedIdentity -ResourceGroupName $rgName

$accessToken = (Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com" -TenantId $TenantID).Token
$authHeader = @{
    'Content-Type'  = 'application/json'
    'Authorization' = 'Bearer ' + $accessToken
}

$authBody = @{
    "principalId"      = $userAssignedId.PrincipalId
    'roleDefinitionId' = "fdd7a751-b60b-444a-984c-02652fe8fa1c"
    'directoryScopeId' = '/'
}

$authBody = $authBody | ConvertTo-Json
        $aadrole = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments" -Method POST -Headers $authHeader -Body $authBody
        $aadrole
