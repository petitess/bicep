# Azure Virtual Desktop with Azure AD Domain Services

## Azure Virtual Desktop - Host Pool, App Groups, Workspace.

If you want to try the setup, do these steps manually:

- Add Azure AD admin user to ADD DC Administrators group 

- Join vm client to Azure AD DC - reset the admin password if you get "referenced account is currently locked out"

- Install on client: Azure Virtual Desktop Agent - [LINK](https://docs.microsoft.com/en-us/azure/virtual-desktop/create-host-pools-powershell?tabs=azure-powershell#register-the-virtual-machines-to-the-azure-virtual-desktop-host-pool)

- Install on client: Azure Virtual Desktop Agent Bootloader - [LINK](https://docs.microsoft.com/en-us/azure/virtual-desktop/create-host-pools-powershell?tabs=azure-powershell#register-the-virtual-machines-to-the-azure-virtual-desktop-host-pool)

- Add a new AD user to connect to AVD

- Add the user to Application group assignments

- Add the user as Virtual Machine User Login in subscription

- Log in to AVD with the link: https://client.wvd.microsoft.com/arm/webclient/index.html

- Or install AVD application from [here](https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/clients/remote-desktop-clients).

- [Azure Virtual Desktop Experience Estimator](https://azure.microsoft.com/en-us/products/virtual-desktop/assessment/#estimation-tool)

<img src="./AVDAAD.png" alt="PE"/>
