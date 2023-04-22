#!/usr/bin/env pwsh

$ErrorActionPreference = 'Stop'

az extension add --name azure-devops

$Product = 'governance'

if (!(az pipelines show  --name "$Product - CI" 2> $null)) {
    az pipelines create --name "$Product - CI" --yml-path "ci/ci.yml" --folder-path $Product
}

if (!(az pipelines show  --name "$Product - CD" 2> $null)) {
    az pipelines create --name "$Product - CD" --yml-path "ci/cd.yml" --folder-path $Product
}
