#!/usr/bin/env pwsh

param (
    #[Parameter(Mandatory)]
    [ValidateScript({ Test-Path $PSScriptRoot/parameters/$_.bicepparam })]
    [String]$Environment = 'dev',

    [ValidateSet('validate', 'what-if', 'create')]
    [String]$Command = 'create',

    [String]$MyIp
)

$ErrorActionPreference = 'Stop'

Set-Location $PSScriptRoot

$Config = Get-Content 'config.json' | ConvertFrom-Json

$Timestamp = Get-Date -UFormat %s

$DeploymentName = "$Environment_$Timestamp"
$TemplateFile = 'main.bicep'
$ParameterFile = "parameters/$Environment.bicepparam"

$D = az deployment sub $Command `
    --name $DeploymentName `
    --subscription $Config.subscription.$Environment `
    --location $Config.location `
    --template-file $TemplateFile `
    --parameters $ParameterFile `
    --no-prompt `
    --output json

$provisioningState = ($D  | ConvertFrom-Json).properties.provisioningState
$amplId = ($D  | ConvertFrom-Json).properties.outputs.amplId.value
$tenantId = ($D  | ConvertFrom-Json).properties.outputs.tenantId.value

if ( $Command -eq 'create' -and $provisioningState -eq 'Succeeded') {
    Write-Output "Deploying private-link association"

    
    az deployment mg create `
        --management-group-id $tenantId `
        --name 'ampl-associations' `
        --location $Config.location `
        --template-file 'ampl_assosiation.bicep' `
        --parameters amplId=$amplId

    #Or you can you azure cli to deploy private-link association
    #az private-link association create --management-group-id $tenantId --name '1d7942d1-288b-48de-8d0f-2d2aa8e03ad4' --privatelink $amplId --public-network-access enabled
}