$DSRMPWord = ConvertTo-SecureString -String "12345678.abc" -AsPlainText -Force

#Write-Verbose "Installing Active Directory Services on this server" -Verbose
    Install-WindowsFeature -Name "AD-Domain-Services" -IncludeManagementTools
    #Write-Verbose "Configuring New Domain with on this server" -Verbose
    Install-ADDSForest -ForestMode WinThreshold -DomainMode WinThreshold -DomainName "domain.my" `
    -InstallDns -NoDNSonNetwork -SafeModeAdministratorPassword $DSRMPWord -Force -NoRebootOnCompletion
    Restart-Computer -Force


  #  Install-ADDSForest -ForestMode WinThreshold -DomainMode WinThreshold -DomainName "karol.se" `
  # -InstallDns -NoDNSonNetwork -Force
  # Uninstall-addsforest -forceremoval -demoteoperationmasterrole