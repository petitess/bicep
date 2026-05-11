main.bicep
```bicep
targetScope = 'subscription'

param is_holiday bool = false
param is_holiday_pwsh string
param date string = utcNow('yyyy-MM-dd')

var public_holidays = [
  '2026-01-01'
  '2026-01-06'
  '2026-04-03'
  '2026-04-06'
  '2026-05-01'
  '2026-05-14'
  '2026-06-06'
  '2026-06-20'
  '2026-10-31'
  '2025-12-24'
  '2025-12-25'
  '2025-12-26'
  '2025-12-31'
]

output public_holidays string = string(contains(public_holidays, date))
output is_holiday string = string(is_holiday)
output is_holiday_pwsh string = is_holiday_pwsh
```
dev.bicepparam
```bicep
using '../main.bicep'

param is_holiday_pwsh = readEnvironmentVariable('is_holiday', 'empty')
```
deploy.ps1
```pwsh
#!/usr/bin/env pwsh

param (
    #[Parameter(Mandatory)]
    # [ValidateScript({ Test-Path $PSScriptRoot/parameters/$_.bicepparam })]
    [String]$Environment = 'dev',

    [ValidateSet('validate', 'what-if', 'create')]
    [String]$Command = 'create'
)

$ErrorActionPreference = 'Stop'

Set-Location $PSScriptRoot

az bicep build --file main.bicep
$content = (Get-Content main.json | ConvertFrom-Json).variables.public_holidays
$date = Get-Date -Format "yyyy-MM-dd"
$env:is_holiday = $content.Contains($date)
Write-Output "is_holiday: $env:is_holiday"

$Config = Get-Content 'config.json' | ConvertFrom-Json

$Timestamp = Get-Date -UFormat %s

$DeploymentName = 'deploy', $Environment, $Timestamp | Join-String -Separator _
$TemplateFile = 'main.bicep'
$ParameterFile = "parameters/$Environment.bicepparam"

az deployment sub $Command `
    --name $DeploymentName `
    --subscription $Config.subscription.($Environment) `
    --location $Config.location `
    --template-file $TemplateFile `
    --parameters $ParameterFile `
    --parameters is_holiday=$env:is_holiday `
    --no-prompt `
    --output table
```
