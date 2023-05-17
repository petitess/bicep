#Run this script when the user managed identity is deployed in the subscription

$TenantID = ""
$subscriptionId = ""

$managedIdentity = "id-script-governance-01"

$rgName = "rg-governance-test-sc-01"

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