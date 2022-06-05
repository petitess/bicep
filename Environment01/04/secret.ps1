#!/usr/bin/env pwsh
$SecretUser = "TestSecret"
Connect-AzAccount -Identity

$GetSecretUser = Get-AzKeyVaultSecret -VaultName $env:KeyVault -Name $SecretUser 

if ($null -eq $GetSecretUser) {
    $user = ConvertTo-SecureString "azadmin" -AsPlainText -Force
    Set-AzKeyVaultSecret -VaultName $env:KeyVault -Name $SecretUser -SecretValue $user
}