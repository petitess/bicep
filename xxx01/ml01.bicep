param kvName string = 'mldefault013957298574'
param appiName string = 'mldefault012654971941'
param astName string = 'mldefault011684541563'
param mlName string = 'ml-default-01'
param agName string = 'Application Insights Smart Detection'
param smartDecName string = 'failure anomalies - mldefault012654971941'
param logId string = '/subscriptions/${subscription().subscriptionId}/resourceGroups/DefaultResourceGroup-swedencentral/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-swedencentral'
param location string = 'swedencentral'

resource agName_resource 'microsoft.insights/actionGroups@2023-01-01' = {
  name: agName
  location: 'Global'
  tags: {
    CostCenter: '12345'
    Environment: 'Production'
    Product: 'Governance'
  }
  properties: {
    groupShortName: 'SmartDetect'
    enabled: true
    emailReceivers: []
    smsReceivers: []
    webhookReceivers: []
    eventHubReceivers: []
    itsmReceivers: []
    azureAppPushReceivers: []
    automationRunbookReceivers: []
    voiceReceivers: []
    logicAppReceivers: []
    azureFunctionReceivers: []
    armRoleReceivers: [
      {
        name: 'Monitoring Contributor'
        roleId: '749f88d5-cbae-40b8-bcfc-e573ddc772fa'
        useCommonAlertSchema: true
      }
      {
        name: 'Monitoring Reader'
        roleId: '43d0d8ad-25c7-4714-9337-8ba259a9fe05'
        useCommonAlertSchema: true
      }
    ]
  }
}

resource appi 'microsoft.insights/components@2020-02-02' = {
  name: appiName
  location: location
  tags: {
    CostCenter: '12345'
    Environment: 'Production'
    Product: 'Governance'
  }
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Redfield'
    Request_Source: 'AzureMachineLearningStudio'
    RetentionInDays: 90
    WorkspaceResourceId: logId
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: kvName
  location: location
  tags: {
    CostCenter: '12345'
    Environment: 'Production'
    Product: 'Governance'
  }
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: 'e44a6fe3-543e-47c1-a8e6-0ab2841227c8'
    accessPolicies: []
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    vaultUri: 'https://${kvName}${environment().suffixes.keyvaultDns}/'
    provisioningState: 'Succeeded'
    publicNetworkAccess: 'Enabled'
  }
}

resource st 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: astName
  location: location
  tags: {
    CostCenter: '12345'
    Environment: 'Production'
    Product: 'Governance'
  }
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    allowCrossTenantReplication: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    isHnsEnabled: false
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource appiConf13 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: appi
  name: 'degradationindependencyduration'
  properties: {
    RuleDefinitions: {
      Name: 'degradationindependencyduration'
      DisplayName: 'Degradation in dependency duration'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource appiConf12 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: appi
  name: 'degradationinserverresponsetime'
  properties: {
    RuleDefinitions: {
      Name: 'degradationinserverresponsetime'
      DisplayName: 'Degradation in server response time'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource appiConf11 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: appi
  name: 'digestMailConfiguration'
  properties: {
    RuleDefinitions: {
      Name: 'digestMailConfiguration'
      DisplayName: 'Digest Mail Configuration'
      Description: 'This rule describes the digest mail preferences'
      HelpUrl: 'www.homail.com'
      IsHidden: true
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource appiConf10 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: appi
  name: 'extension_billingdatavolumedailyspikeextension'
  properties: {
    RuleDefinitions: {
      Name: 'extension_billingdatavolumedailyspikeextension'
      DisplayName: 'Abnormal rise in daily data volume (preview)'
      Description: 'This detection rule automatically analyzes the billing data generated by your application, and can warn you about an unusual increase in your application\'s billing costs'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/tree/master/SmartDetection/billing-data-volume-daily-spike.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource appiConf9 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: appi
  name: 'extension_canaryextension'
  properties: {
    RuleDefinitions: {
      Name: 'extension_canaryextension'
      DisplayName: 'Canary extension'
      Description: 'Canary extension'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/'
      IsHidden: true
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource appiConf8 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: appi
  name: 'extension_exceptionchangeextension'
  properties: {
    RuleDefinitions: {
      Name: 'extension_exceptionchangeextension'
      DisplayName: 'Abnormal rise in exception volume (preview)'
      Description: 'This detection rule automatically analyzes the exceptions thrown in your application, and can warn you about unusual patterns in your exception telemetry.'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/abnormal-rise-in-exception-volume.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource appiConf7 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: appi
  name: 'extension_memoryleakextension'
  properties: {
    RuleDefinitions: {
      Name: 'extension_memoryleakextension'
      DisplayName: 'Potential memory leak detected (preview)'
      Description: 'This detection rule automatically analyzes the memory consumption of each process in your application, and can warn you about potential memory leaks or increased memory consumption.'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/tree/master/SmartDetection/memory-leak.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource appiConf6 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: appi
  name: 'extension_securityextensionspackage'
  properties: {
    RuleDefinitions: {
      Name: 'extension_securityextensionspackage'
      DisplayName: 'Potential security issue detected (preview)'
      Description: 'This detection rule automatically analyzes the telemetry generated by your application and detects potential security issues.'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/application-security-detection-pack.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource appiConf5 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: appi
  name: 'extension_traceseveritydetector'
  properties: {
    RuleDefinitions: {
      Name: 'extension_traceseveritydetector'
      DisplayName: 'Degradation in trace severity ratio (preview)'
      Description: 'This detection rule automatically analyzes the trace logs emitted from your application, and can warn you about unusual patterns in the severity of your trace telemetry.'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/degradation-in-trace-severity-ratio.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource appiConf4 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: appi
  name: 'longdependencyduration'
  properties: {
    RuleDefinitions: {
      Name: 'longdependencyduration'
      DisplayName: 'Long dependency duration'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource appiConf3 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: appi
  name: 'migrationToAlertRulesCompleted'
  properties: {
    RuleDefinitions: {
      Name: 'migrationToAlertRulesCompleted'
      DisplayName: 'Migration To Alert Rules Completed'
      Description: 'A configuration that controls the migration state of Smart Detection to Smart Alerts'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: true
      IsEnabledByDefault: false
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: false
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource appiConf2 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: appi
  name: 'slowpageloadtime'
  properties: {
    RuleDefinitions: {
      Name: 'slowpageloadtime'
      DisplayName: 'Slow page load time'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource appiConf1 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: appi
  name: 'slowserverresponsetime'
  properties: {
    RuleDefinitions: {
      Name: 'slowserverresponsetime'
      DisplayName: 'Slow server response time'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource sec5 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: kv
  name: 'b1ac0f5b-ce19-42d6-9332-657b4fdd61cb-FAgyKm1gPT3CPGSbzlZBLG7LN6vYTa3HVnL0p1ldOfE'
  properties: {
    contentType: 'application/vnd.ms-StorageAccountAccessKey'
    attributes: {
      enabled: true
      exp: 1765975588
    }
  }
}

resource sec4 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: kv
  name: 'b1ac0f5b-ce19-42d6-9332-657b4fdd61cb-FwGDdi55bVL4Aq3jBeTugznDoAnRMkVpIu5BCekvkag'
  properties: {
    contentType: 'application/vnd.ms-StorageAccountAccessKey'
    attributes: {
      enabled: true
      exp: 1765975588
    }
  }
}

resource sec3 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: kv
  name: 'b1ac0f5b-ce19-42d6-9332-657b4fdd61cb-HxopeYA5gAqcSVekcWcNytXWT7D6jV-Fj-ARhX2wVsA'
  properties: {
    contentType: 'application/vnd.ms-StorageAccountAccessKey'
    attributes: {
      enabled: true
      exp: 1765975588
    }
  }
}

resource sec2 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: kv
  name: 'b1ac0f5b-ce19-42d6-9332-657b4fdd61cb-i3pZPxcONfJy3MhnYVF4y0-qLVIzaR2Fmw8X6xoQ2JE'
  properties: {
    contentType: 'application/vnd.ms-StorageAccountAccessKey'
    attributes: {
      enabled: true
      exp: 1765975588
    }
  }
}

resource sec1 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: kv
  name: 'b1ac0f5b-ce19-42d6-9332-657b4fdd61cb-K-xstAZfmyqDGfAeCS6N3u4pyiMHLKALPUSUm9acc-s'
  properties: {
    contentType: 'application/vnd.ms-StorageAccountAccessKey'
    attributes: {
      enabled: true
      exp: 1765977353
    }
  }
}

resource mlData5 'Microsoft.MachineLearningServices/workspaces/datastores@2023-10-01' = {
  parent: ml
  name: 'azureml_globaldatasets'
  properties: {
    datastoreType: 'AzureBlob'
    credentials: {
      credentialsType: 'Sas'
      secrets: {
        secretsType: 'AccountKey'
      }
    }
  }
}

resource mlData4 'Microsoft.MachineLearningServices/workspaces/datastores@2023-10-01' = {
  parent: ml
  name: 'workspaceartifactstore'
  properties: {
    datastoreType: 'AzureBlob'
    credentials: {
      credentialsType: 'AccountKey'
      secrets: {
        secretsType: 'AccountKey'
      }
    }
  }
}

resource mlData3 'Microsoft.MachineLearningServices/workspaces/datastores@2023-10-01' = {
  parent: ml
  name: 'workspaceblobstore'
  properties: {
    datastoreType: 'AzureBlob'
    credentials: {
      credentialsType: 'AccountKey'
      secrets: {
        secretsType: 'AccountKey'
      }
    }
  }
}

resource mlData2 'Microsoft.MachineLearningServices/workspaces/datastores@2023-10-01' = {
  parent: ml
  name: 'workspacefilestore'
  properties: {
    datastoreType: 'AzureFile'
    accountName: st.name
    fileShareName: share2.name
    credentials: {
      credentialsType: 'AccountKey'
      secrets: {
        secretsType: 'AccountKey'
        key: st.listKeys().keys[0].value
      }
    }
  }
}

resource mlData1 'Microsoft.MachineLearningServices/workspaces/datastores@2023-10-01' = {
  parent: ml
  name: 'workspaceworkingdirectory'
  properties: {
    datastoreType: 'AzureFile'
    accountName: st.name
    fileShareName: share1.name
    credentials: {
      credentialsType: 'AccountKey'
      secrets: {
        secretsType: 'AccountKey'
        key: st.listKeys().keys[0].value
      }
    }
  }
}

resource blobSvc 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: st
  name: 'default'
  properties: {
    cors: {
      corsRules: [
        {
          allowedOrigins: [
            'https://mlworkspace.azure.ai'
            'https://ml.azure.com'
            'https://*.ml.azure.com'
            'https://ai.azure.com'
            'https://*.ai.azure.com'
          ]
          allowedMethods: [
            'GET'
            'HEAD'
            'POST'
            'PUT'
            'DELETE'
            'OPTIONS'
            'PATCH'
          ]
          maxAgeInSeconds: 1800
          exposedHeaders: [
            '*'
          ]
          allowedHeaders: [
            '*'
          ]
        }
      ]
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: false
    }
  }
}

resource filesvc 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' = {
  parent: st
  name: 'default'
  properties: {
    protocolSettings: {
      smb: {}
    }
    cors: {
      corsRules: []
    }
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

resource queue1 'Microsoft.Storage/storageAccounts/queueServices@2023-01-01' = {
  parent: st
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource table1 'Microsoft.Storage/storageAccounts/tableServices@2023-01-01' = {
  parent: st
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource smartDec 'microsoft.alertsmanagement/smartdetectoralertrules@2021-04-01' = {
  name: smartDecName
  location: 'global'
  tags: {
    CostCenter: '12345'
    Environment: 'Production'
    Product: 'Governance'
  }
  properties: {
    description: 'Failure Anomalies notifies you of an unusual rise in the rate of failed HTTP requests or dependency calls.'
    state: 'Enabled'
    severity: 'Sev3'
    frequency: 'PT1M'
    detector: {
      id: 'FailureAnomaliesDetector'
    }
    scope: [
      appi.id
    ]
    actionGroups: {
      groupIds: [
        agName_resource.id
      ]
    }
  }
}

resource blobSvc_azureml 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobSvc
  name: 'azureml'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
}

resource blobSvc_azureml_blobstore_b1ac0f5b_ce19_42d6_9332_657b4fdd61cb 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobSvc
  name: 'azureml-blobstore-b1ac0f5b-ce19-42d6-9332-657b4fdd61cb'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
}

resource share2 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = {
  parent: filesvc
  name: 'azureml-filestore-b1ac0f5b-ce19-42d6-9332-657b4fdd61cb'
  properties: {
    accessTier: 'TransactionOptimized'
    shareQuota: 5120
    enabledProtocols: 'SMB'
  }
}

resource share1 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = {
  parent: filesvc
  name: 'code-391ff5ac-6576-460f-ba4d-7e03433c68b6'
  properties: {
    accessTier: 'TransactionOptimized'
    shareQuota: 5120
    enabledProtocols: 'SMB'
  }
}

resource ml 'Microsoft.MachineLearningServices/workspaces@2023-10-01' = {
  name: mlName
  tags: {
    CostCenter: '12345'
    Environment: 'Production'
    Product: 'Governance'
  }
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  kind: 'Default'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: mlName
    storageAccount: st.id
    keyVault: kv.id
    applicationInsights: appi.id
    hbiWorkspace: false
    managedNetwork: {
      isolationMode: 'Disabled'
    }
    v1LegacyMode: false
    publicNetworkAccess: 'Enabled'
    discoveryUrl: 'https://swedencentral.api.azureml.ms/discovery'
  }
}
