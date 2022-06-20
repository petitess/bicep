$subscripionList = Get-AzSubscription 


foreach ($subscriptionId in $subscripionList) {
    Write-Host 'Getting details about SubscriptionId :' $subscriptionId
    Set-AzContext -Subscription $subscriptionId
    #Select-AzureRmSubscription -SubscriptionName $subscriptionId

    $resourcesgroups = Get-AzResourceGroup

    foreach($resourcesgroup in $resourcesgroups){

    Write-Host 'resourcegroup :' $resourcesgroup
   
    $resources = Get-AzResource -ResourceGroupName $resourcesgroup.ResourceGroupName
       #$azure_resources = Get-AzResource 


    foreach($resource in $resources){

    Write-Host $resource
{
    #Fetching Tags
    $Tags = $resource.Tags
    
    #Checkign if tags is null or have value
    if($Tags -ne $null)
    {
        foreach($Tag in $Tags)
        {
            $TagsAsString += $Tag.Name + ":" + $Tag.Value + ";"
        }
    }
    else
    {
        $TagsAsString = "NULL"
    } 
}
}
}