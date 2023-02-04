#!/usr/bin/env pwsh

param ( 
    [Parameter(Mandatory)]    
    [String]    
    $Environment
)

Write-Output "Hej! $Environment"