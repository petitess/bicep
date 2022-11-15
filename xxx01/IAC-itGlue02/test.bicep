param sites_app_int_almiprod_we_01_name string = 'app-int-almiprod-we-01'
param serverfarms_plan_int_almiprod_we_02_externalid string = '/subscriptions/86105c75-6e59-4a09-a280-032c16eb6c44/resourceGroups/rg-int-almiprod-we-shared/providers/Microsoft.Web/serverfarms/plan-int-almiprod-we-02'

resource sites_app_int_almiprod_we_01_name_resource 'Microsoft.Web/sites@2022-03-01' = {
  name: sites_app_int_almiprod_we_01_name
  location: 'West Europe'
  tags: {
    ApplicationName: 'Integration'
    InfrastructureAsCode: 'true'
    Environment: 'Production'
  }
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${sites_app_int_almiprod_we_01_name}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${sites_app_int_almiprod_we_01_name}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: serverfarms_plan_int_almiprod_we_02_externalid
    reserved: false
    isXenon: false
    hyperV: false
    vnetRouteAllEnabled: false
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
    siteConfig: {
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      alwaysOn: true
      http20Enabled: true
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 1
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    customDomainVerificationId: 'A16B370C8FEE2090273446DEC267C9A8F75BFEC7EE784E9B0155D8C4FC6E01CA'
    containerSize: 0
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

resource sites_app_int_almiprod_we_01_name_ftp 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
  parent: sites_app_int_almiprod_we_01_name_resource
  name: 'ftp'
  location: 'West Europe'
  tags: {
    ApplicationName: 'Integration'
    InfrastructureAsCode: 'true'
    Environment: 'Production'
  }
  properties: {
    allow: true
  }
}

resource sites_app_int_almiprod_we_01_name_scm 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
  parent: sites_app_int_almiprod_we_01_name_resource
  name: 'scm'
  location: 'West Europe'
  tags: {
    ApplicationName: 'Integration'
    InfrastructureAsCode: 'true'
    Environment: 'Production'
  }
  properties: {
    allow: true
  }
}

resource sites_app_int_almiprod_we_01_name_web 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: sites_app_int_almiprod_we_01_name_resource
  name: 'web'
  location: 'West Europe'
  tags: {
    ApplicationName: 'Integration'
    InfrastructureAsCode: 'true'
    Environment: 'Production'
  }
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
      'hostingstart.html'
    ]
    netFrameworkVersion: 'v4.0'
    phpVersion: '5.6'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: '$app-int-almiprod-we-01'
    scmType: 'VSTSRM'
    use32BitWorkerProcess: true
    webSocketsEnabled: false
    alwaysOn: true
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: true
      }
      {
        virtualPath: '/AzureInventering.Sub1'
        physicalPath: 'site\\wwwroot\\app_data\\jobs\\triggered\\AzureInventering.Sub1'
        preloadEnabled: true
      }
      {
        virtualPath: '/AzureInventering.Sub2'
        physicalPath: 'site\\wwwroot\\app_data\\jobs\\triggered\\AzureInventering.Sub2'
        preloadEnabled: true
      }
      {
        virtualPath: '/AzureInventering.Sub3'
        physicalPath: 'site\\wwwroot\\app_data\\jobs\\triggered\\AzureInventering.Sub3'
        preloadEnabled: true
      }
      {
        virtualPath: '/AzureInventering.Sub4'
        physicalPath: 'site\\wwwroot\\app_data\\jobs\\triggered\\AzureInventering.Sub4'
        preloadEnabled: true
      }
      {
        virtualPath: '/AzureInventering.Sub5'
        physicalPath: 'site\\wwwroot\\app_data\\jobs\\triggered\\AzureInventering.Sub5'
        preloadEnabled: true
      }
      {
        virtualPath: '/UpdateItGlue'
        physicalPath: 'site\\wwwroot\\app_data\\jobs\\triggered\\UpdateItGlue'
        preloadEnabled: true
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    vnetRouteAllEnabled: false
    vnetPrivatePortsCount: 0
    localMySqlEnabled: false
    managedServiceIdentityId: 29953
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: true
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.0'
    ftpsState: 'FtpsOnly'
    preWarmedInstanceCount: 0
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: 1
    azureStorageAccounts: {
    }
  }
}