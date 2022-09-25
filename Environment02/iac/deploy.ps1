#!/usr/bin/env pwsh

param (
    [Parameter(Mandatory)]
    [String]
    $Environment,

    [Parameter()]
    [Switch]
    $Validate
)

$ErrorActionPreference = 'Stop'

Set-Location $PSScriptRoot

$ConfigFile = Join-Path 'config' "$Environment.config.json"
$Config = Get-Content $ConfigFile | ConvertFrom-Json

$Timestamp = Get-Date -Format 'yyyy-MM-dd_HHmmss'
$Repo = Split-Path -Leaf (git remote get-url origin).Replace('.git', '')
$DeploymentName = '{0}_{1}_{2}' -f $Repo, $Environment, $Timestamp

$ParameterFile = Join-Path 'parameters' "$Environment.parameters.json"
$Arguments = '--name', $DeploymentName, '--subscription', $Config.subscription, '--location', $Config.location, '--template-file', $Config.templateFile, '--parameters', "@$ParameterFile", '--no-prompt', '--output', 'table'

if ($Validate) {
    az deployment sub validate $Arguments
    az deployment sub what-if $Arguments
}
else {
    az deployment sub create $Arguments
}
