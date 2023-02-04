#!/usr/bin/env pwsh

$ErrorActionPreference = 'Stop'

az extension add --name azure-devops

$LandingZones = (Get-ChildItem -Path 'landingzones').Name

foreach ($LandingZone in $LandingZones) {
    if (!(az pipelines show  --name $LandingZone 2> $null)) {
        az pipelines create --name $LandingZone --yml-path "landingzones/$LandingZone/lz.yml" --folder-path 'landingzones'
    }
}





#https://learn.microsoft.com/en-us/rest/api/azure/devops/distributedtask/environments/add?view=azure-devops-rest-6.0
#https://learn.microsoft.com/en-us/cli/azure/repos/policy?view=azure-cli-latest