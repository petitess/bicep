targetScope = 'subscription'

@description('Allow Azure services and resources to access this server must be set to yes')
module SQL1 'policies/sql-allow-azure-access.bicep' = {
  name: 'SQL1'
}
@description('App Service Basic, Standard, PremiumV2, and PremiumV3 are the only tiers authorized')
module APP1 'policies/app-allowed-sku.bicep' = {
  name: 'APP1'
}
@description('Required Tags Container Registry')
module ACR1 'policies/acr-allowed-tags.bicep' = {
  name: 'ACR1'
}
@description('Required Tags App Service')
module APP2 'policies/app-allowed-tags.bicep' = {
  name: 'APP2'
}
@description('Azure Defender must be enabled for C2 handling App Service')
module APP3 'policies/app-require-defender.bicep' = {
  name: 'APP3'
}
@description('For availability needs A3, zone redundant App Service Plan must be enabled')
module ASP1 'policies/asp-require-zone-redundancy.bicep' = {
  name: 'ASP1'
}
@description('CORS should not allow every resource to access your APPS')
module APP4 'policies/app-cors-dont-allow-all.bicep' = {
  name: 'APP4'
}
@description('The app must use a certificate stored in a Key Vault')
module APP5 'policies/app-require-cert-in-kv.bicep' = {
  name: 'APP5'
}
@description('Diagnostics logs must enabled')
module APP6 'policies/app-require-diagnostic-logs.bicep' = {
  name: 'APP6'
}
@description('SCM network firewall must allow only access from authorized IP adresses')
module APP7 'policies/app-network-scm.bicep' = {
  name: 'APP7'
}
@description('The App must not have an embedded mysql DB')
module APP8 'policies/app-unallow-embedded-mysql-db.bicep' = {
  name: 'APP8'
}
@description('App Service Private endpoint must be configured')
module APP9 'policies/app-require-pep.bicep' = {
  name: 'APP9'
}
@description('Websocket must be disabled')
module APP10 'policies/app-unallow-websocket.bicep' = {
  name: 'APP10'
}
@description('Production ressources must be locked against deletion')
module RES1 'policies/res-require-resource-lock.bicep' = {
  name: 'RES1'
}
@description('Detect resources deployed outside of allowed regions')
module RES2 'policies/res-detect-resources-unallowed-regions.bicep' = {
  name: 'RES2'
}
@description('Configure Linux Machines to be associated with a Data Collection Rule or a Data Collection Endpoint')
module VM1 'policies/vm-config-data-collection-rule-linux.bicep' = {
  name: 'VM1'
}
@description('Analysis Services. Default Backup should not be used')
module AAS1 'policies/aas-unallow-backup.bicep' = {
  name: 'AAS1'
}
@description('Analysis Services. The Firewall must whitelist IPs for users connecting through the Public Endpoint')
module AAS2 'policies/aas-required-ips.bicep' = {
  name: 'AAS2'
}
@description('Analysis Services. Developer tier must not be used in production environment')
module AAS3 'policies/aas-unallow-developer-tier.bicep' = {
  name: 'AAS3'
}
@description('Analysis Services. Diagnostic settings must be enabled')
module AAS4 'policies/aas-require-diagnostic-settings.bicep' = {
  name: 'AAS4'
}
@description('Analysis Services. The Firewall of the service must be enabled')
module AAS5 'policies/aas-require-firewall.bicep' = {
  name: 'AAS5'
}
@description('Analysis Services. If the client is using PowerBI, the Firewall rules must be configured to allow all PowerBI IPs')
module AAS6 'policies/aas-require-firewall-powerbi.bicep' = {
  name: 'AAS6'
}
@description('Azure Grafana managed instance must be deployed using the Standard Plan')
module AMG1 'policies/amg-require-standard-sku.bicep' = {
  name: 'AMG1'
}
@description('Role assignment must be done through an Azure AD group (no direct user assignment)')
module RES3 'policies/res-require-rbac-entraid-group.bicep' = {
  name: 'RES3'
}
@description('Web App Firewall must only allow access from specific IPs')
module APP11 'policies/app-allow-access-from-ips.bicep' = {
  name: 'APP11'
}
@description('Diagnostics settings must be enabled for Internal Load Balancer')
module ALB1 'policies/alb-require-diagnostic-settings.bicep' = {
  name: 'ALB1'
}
@description('Managed private endpoints must be used to setup a private connection between Azure Grafana and private supported Azure data sources')
module AMG2 'policies/amg-require-managed-pep.bicep' = {
  name: 'AMG2'
}
@description('Web App Minimum_tls_version must be 1.2 or 1.3')
module APP12 'policies/app-require-tls.bicep' = {
  name: 'APP12'
}
@description('Storage. Public blob access is not authorized')
module ST1 'policies/st-unallow-public-access-blob.bicep' = {
  name: 'ST1'
}
@description('Function. FTPS / git accounts must be disabled')
module FUNC1 'policies/func-unallow-FTPS.bicep' = {
  name: 'FUNC1'
}
@description('VNet rules must allow flow only from vNets of the same subscription')
module KV1 'policies/kv-require-vnet-rules-subscription.bicep' = {
  name: 'KV1'
}
@description('API Managment. The configuration must contain a CORS block (Global API level)')
module APIM1 'policies/apim-require-cors.bicep' = {
  name: 'APIM1'
}
@description('Public IP card are not allowed')
module VM2 'policies/vm-unallow-public-nic.bicep' = {
  name: 'VM2'
}
@description('Enable source control on development data factories by using a Git repository')
module ADF1 'policies/adf-require-source-control.bicep' = {
  name: 'ADF1'
}
@description('Diagnostic logs for user-driven events (pull/push etc) in your registry must be logged within Azure Monitor')
module ACR2 'policies/acr-require-diagnostric-settings.bicep' = {
  name: 'ACR2'
}
@description('Private endpoint must be enabled and assigned  & No vnet rule must be configured')
module SQL2 'policies/sql-require-pep.bicep' = {
  name: 'SQL2'
}
@description('Retention policy must be activated')
module ACR3 'policies/acr-require-retention.bicep' = {
  name: 'ACR3'
}
@description('IP rules must be set to allow traffic only from specific IPs')
module ST2 'policies/st-allow-access-from-ips.bicep' = {
  name: 'ST2'
}
@description('Publicly HTTPS exposed Functions must use the WAF')
module FUNC2 'policies/func-require-WAF.bicep' = {
  name: 'FUNC2'
}
@description('IP rules must be set to Deny traffic from Internet')
module ST3 'policies/st-unallow-internet-trafic.bicep' = {
  name: 'ST3'
}
@description('Soft delete must be enabled on Key Vault')
module KV2 'policies/kv-require-soft-delete.bicep' = {
  name: 'KV2'
}
@description('Allow only Ecrypted Database')
module SQL3 'policies/sql-require-encryption.bicep' = {
  name: 'SQL3'
}
@description('Auditing for Azure SQL Database must be activated and stored at least 90days')
module SQL4 'policies/sql-require-auditing-logs-90.bicep' = {
  name: 'SQL4'
}
@description('No any-to-any rule must be configured')
module SQL5 'policies/sql-unallow-any-to-any.bicep' = {
  name: 'SQL5'
}
@description('Advanced Data Security must be configured')
module SQL6 'policies/sql-require-adanced-data-security.bicep' = {
  name: 'SQL6'
}
@description('Firewall rules do not allow all network')
module KV3 'policies/kv-unallow-all-networks.bicep' = {
  name: 'KV3'
}
@description('Azure Key Vault public access must be disabled')
module KV4 'policies/kv-unallow-public-access.bicep' = {
  name: 'KV4'
}
@description('System managed Identity must be enabled')
module APIM2 'policies/apim-require-msi.bicep' = {
  name: 'APIM2'
}
@description('Enforce JWT verification (Global API Policies)')
module APIM3 'policies/apim-audit-jwt-verification.bicep' = {
  name: 'APIM3'
}
@description('Azure defender for storage must be enabled')
module ST4 'policies/st-require-defender.bicep' = {
  name: 'ST4'
}

@description('Dont allow any source')
module ST4 'policies/afw-unallow-any-source.bicep' = {
  name: 'AFWP1'
}

