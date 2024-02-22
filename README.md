<details><summary>Setup</summary><p>

Install [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli)

Install [Bicep CLI](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)

Install [Azure Az PowerShell module](https://learn.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-9.1.0)

Install [Bicep VS Code extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep)

```
New-AzSubscriptionDeployment -TemplateFile main.bicep -TemplateParameterFile param.json -Location "swedencentral" -Name Deploy$(Get-Date -Format 'yyyy-MM-dd')
```
</p></details> 

<details><summary>Info</summary><p>

[Abbreviation examples for Azure resources](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)

[Naming rules and restrictions for Azure resources](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules)

</p></details> 

## Content

| Name | Description | 
|--|--|
| aadds01 | Azure AD Domain Services 
| alert01 | Service Health Alerts  
| alert02 | Log Analytics query alerts 
| alert03 | Log Analytics query alerts with suppression rule 
| alert04 | VM resource health alerts
| apiconnection01 | API connection
| applicationgateway01 | Azure Application Gateway Public IIS 
| applicationgateway02 | Multi site listeners, https, cert, redirect, rewrites
| applicationinsights01 | Application Insights with Availability Test
| appserviceplan01 | Azure App Service Plan integrated with vnet 
| appserviceplan02 | Google Tag Manager with Availability test 
| appserviceplan03 | ITglue integration
| appserviceplan04 | App service with PEP and Vnet integration
| appserviceplan05 | PEP for slots 
| appserviceplan06 | Install Azure App Service Managed Certificate 
| appserviceplan07 | Install Azure App Service Certificate + Custom Domain
| appserviceplan08 | App service + SQL + PEP + ASP.NET app deployment 
| automationaccount01 | Schedule On-Demand Azure File Share Snapshots
| automationaccount02 | Scheduled Runbooks 
| availabilityset01 | Availability set VMs combined with Non-availability set VMs 
| availabilityset02 | Multiple availability sets 
| azurefirewall01 | Azure Firewall Policy - DNAT, Network, Application rule 
| azurefirewall02 | AGW routed through AFW
| certificates01 | Certificates + lock 
| citrix01 | Citrix NetScaler(ADC) with high-availability(HA) 
| containerregistry01 | azure container registry - push/pull docker image
| deploymentscript01 | Create EntraId groups & Add managed identity as member
| diag01 | Diagnostic settings 
| dns01 | Microsoft.Network/dnsZones 
| dns02 | Microsoft.Network/dnsZones-array 
| frontdoor01 | Virtual Machines (pip loop) as Backend pool
| frontdoor02 | Front Door, Endpoints, WAF, Private Link Services
| functionapp01 | Function App
| functionapp02 | Schedule On-Demand Azure File Share Snapshots
| functionapp03 | empty func powershell app + appi + yaml
| keyvault01 | Create Secrets for VMs 
| keyvault02 | Create Secrets for VMs - multiple modules
| keyvault03 | uniqueString() to generate password 
| kubernetes01 | Azure Kubernetes services 
| kubernetes02 | Azure Kubernetes services - Azure CNI
| loadbalancer01 | Internal Azure Load Balancer with Rules
| loadbalancer02 | External Load Balancer
| logicapp01 | AD password expiration notification(Consumption) 
| logicapp02 | Resource Graph Query - email
| logicapp03 | Copy blobs 
| maintenance01 | Dynamic scopes
| peering01 | Virtual network peering 
| policy01 | Not Allowed Resource Types - Rescource Group 
| policy02 | Cloud Adoption Framework
| privatelink01 | Load Balancer with Private Link connected to another vnet
| privatelink02 | Private Endpoint - Fileshare - Peering - Vnet-to-Vnet
| privatelink03 | Private Endpoint for both File and Blob
| privatelink04 | Private Endpoint for Azure SQL
| privatelink05 | Log Analytics & Appilcation Insight PL to Azure Monitor
| privatelink06| Private Endpoint for File, Blob 
| rbac01 | Multiple roles
| rbac02 | Tenant Root Group assignment 
| runcommand01 | powershell script
| searchservice01 | Search service + Sql + Pep + Automated approval 
| siterecovery01 | Azure Site Recovery 
| storageaccount01 | Fileshare with backup
| storageaccount02 | Fileshare with backup
| subscription01 | Create subscriptions
| tags01 | Tags - comparison operators 
| template01 | VNET
| template02 | 3 VNETs
| template03 | A virtual machine with bastion
| tenant01 | Azure landing zone
| virtualdesktop01 | Host Pool, App Group, Workspace, FXLogix, Registry settings
| virtualdesktop02 | Azure Virtual Desktop with Azure AD Domain Services
| virtualdesktop03 | Azure Virtual Desktop 100%
| virtualmachine01 | VM extension: AD Domain Services
| virtualmachine02 | VM extension: AD Domain Services + Join Domain
| virtualmachine03 | VM extension: IIS
| virtualmachine04 | VM extension: Nginx on Linux
| virtualmachine05 | Create a VM from an image
| virtualmachine06 | Availability sets - filter() function
| virtualmachine07 | Add Log Analytics to existing VMs
| virtualmachine08 | A template to deploy Azure Monitor Agent
| virtualnetworkgateway01 | Multiple S2S-connections, Key Vault Secret
| virtualnetworkgateway02 | Virtual network gateway: VNet-to-VNet connection
| virtualnetworkgateway03 | Virtual network gateway: Azure AD authentication
| virtualnetworkgateway04 | S2S VPN between subscriptions with BGP
| vmgallery01 | VM gallery, VM image definition and VM image version
| vmgallery02 | VM gallery with VM deployment
| vmss01 | VM scale set for DevOps Linux & Windows(Legacy) 
| vmss02 | VM scale set for DevOps
| wan01 | Azure Virtual WAN with P2S configuration
| wan02 | Virtual network connections and VPN sites
