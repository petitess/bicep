targetScope = 'subscription'

param config object
param environment string
param location string = deployment().location
param vnet object
param kv object

var prefix = toLower('${config.product}-sys-${environment}-${config.location}')
var prefixAdf = toLower('${config.product}-adf-${environment}-${config.location}')
var prefixDbw = toLower('${config.product}-dbw-${environment}-${config.location}')
var prefixSql = toLower('${config.product}-sql-${environment}-${config.location}')
var prefixSynw = toLower('${config.product}-synw-${environment}-${config.location}')
var kvName = 'kv-${prefix}-001'
var myIp = '188.150.1.1'
var databricksExists = true
var synapseExists = true
var stDlName = toLower('st${config.product}datalake${environment}01')
var sqlGroup = {
  name: 'grp-infra-contributor'
  objectId: '09cf7cc4-7e5d-4c75-96f4-4667c4a4f4fd'
}

var domains = [
  'privatelink${az.environment().suffixes.sqlServerHostname}'
  'privatelink.datafactory.azure.net'
  'privatelink.vaultcore.azure.net'
  'privatelink.blob.${az.environment().suffixes.storage}'
  'privatelink.dfs.${az.environment().suffixes.storage}'
  'privatelink.azuredatabricks.net'
  'privatelink.sql.azuresynapse.net'
  'privatelink.dev.azuresynapse.net'
  'privatelink.azuresynapse.net'
]

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${prefix}-01'
  location: location
  tags: union(
    config.tags,
    {
      System: config.product
    }
  )
}
resource rgAdf 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${prefixAdf}-01'
  location: location
  tags: union(
    config.tags,
    {
      System: 'Data Factory'
    }
  )
}

resource rgSql 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${prefixSql}-01'
  location: location
  tags: union(
    config.tags,
    {
      System: 'Azure SQL'
    }
  )
}

resource rgDbw 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${prefixDbw}-01'
  location: location
  tags: union(
    config.tags,
    {
      System: 'Data Bricks'
    }
  )
}

resource rgSynw 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${prefixSynw}-01'
  location: location
  tags: union(
    config.tags,
    {
      System: 'Synapse'
    }
  )
}

module vnetM 'modules/vnet.bicep' = {
  name: 'vnet'
  scope: rg
  params: {
    prefix: prefix
    location: location
    addressPrefixes: vnet.addressPrefixes
    subnets: vnet.subnets
    flowLogsEnabled: false
  }
}

module pdnsz 'modules/pdnsz.bicep' = [
  for (domain, i) in domains: {
    name: 'pdnsz_${split(domain, '.')[1]}'
    scope: rg
    params: {
      name: domain
      vnetName: vnetM.outputs.name
      vnetId: vnetM.outputs.id
    }
  }
]

module kvM 'modules/kv.bicep' =
  if (!empty(kv)) {
    scope: rg
    name: 'kv'
    params: {
      location: location
      name: kvName
      sku: kv.sku
      enabledForDeployment: kv.enabledForDeployment
      enabledForDiskEncryption: kv.enabledForDiskEncryption
      enabledForTemplateDeployment: kv.enabledForTemplateDeployment
      enableRbacAuthorization: kv.enableRbacAuthorization
      snetId: vnetM.outputs.snet['snet-pep'].id
      allowedIps: [
        myIp
      ]
    }
  }

module sqlM 'modules/sql.bicep' = {
  scope: rgSql
  name: 'sql'
  params: {
    name: 'sql-${prefixAdf}-01'
    location: location
    tags: config.tags
    admingroupname: sqlGroup.name
    admingroupobjectid: sqlGroup.objectId
    password: '12345678.abC'
    peSnetId: vnetM.outputs.snet['snet-pep'].id
    rgDns: rg.name
    username: 'sqladmin'
    firewallRules: [
      {
        name: 'AllowAllWindowsAzureIps'
        properties: {
          startIpAddress: '0.0.0.0'
          endIpAddress: '0.0.0.0'
        }
      }
      {
        name: 'self_hosted'
        properties: {
          startIpAddress: '104.40.224.111'
          endIpAddress: '104.40.224.111'
        }
      }
    ]
    dbs: [
      {
        name: 'sqldb-adf-log'
        sku: {
          name: 'GP_S_Gen5'
          tier: 'GeneralPurpose'
          family: 'Gen5'
          capacity: 1
        }
        properties: {
          autopausedelay: 60
          availabilityzone: 'NoPreference'
          zoneredundant: false
          collation: 'SQL_Latin1_General_CP1_CI_AS'
        }
      }
      {
        name: 'sqldb-datakaj'
        sku: {
          name: 'GP_S_Gen5'
          tier: 'GeneralPurpose'
          family: 'Gen5'
          capacity: 1
        }
        properties: {
          autopausedelay: 60
          availabilityzone: 'NoPreference'
          zoneredundant: false
          collation: 'SQL_Latin1_General_CP1_CI_AS'
        }
      }
      {
        name: 'sqldb-datatorg'
        sku: {
          name: 'GP_Gen5'
          tier: 'GeneralPurpose'
          family: 'Gen5'
          capacity: 2
        }
        properties: {
          autopausedelay: 60
          availabilityzone: 'NoPreference'
          zoneredundant: false
          collation: 'SQL_Latin1_General_CP1_CI_AS'
        }
      }
      {
        name: 'sqldb-datafabrik'
        sku: {
          name: 'GP_S_Gen5'
          tier: 'GeneralPurpose'
          family: 'Gen5'
          capacity: 1
        }
        properties: {
          autopausedelay: 60
          availabilityzone: 'NoPreference'
          zoneredundant: false
          collation: 'SQL_Latin1_General_CP1_CI_AS'
        }
      }
    ]
  }
}

module st 'modules/st.bicep' = {
  scope: rg
  name: 'stmonitor'
  params: {
    name: toLower('st${config.product}monitor${environment}01')
    location: location
    dnsRgName: rg.name
    snetId: vnetM.outputs.snet['snet-pep'].id
    networkAcls: {
      resourceAccessRules: []
      bypass: 'AzureServices'
      ipRules: []
      defaultAction: 'deny'
    }
    privateEndpoints: [
      'blob'
    ]
  }
}

module stDl 'modules/st.bicep' = {
  scope: rg
  name: 'stdatalake'
  params: {
    name: stDlName
    location: location
    dnsRgName: rg.name
    snetId: vnetM.outputs.snet['snet-pep'].id
    hierarchicalNamespace: true
    networkAcls: {
      resourceAccessRules: []
      bypass: 'AzureServices'
      ipRules: []
      defaultAction: 'deny'
    }
    privateEndpoints: [
      'dfs'
    ]
  }
}

module stDl2 'modules/st.bicep' = {
  scope: rg
  name: 'stdatalake2'
  params: {
    name: toLower('st${config.product}datalake${environment}02')
    location: location
    dnsRgName: rg.name
    snetId: vnetM.outputs.snet['snet-pep'].id
    hierarchicalNamespace: true
    networkAcls: {
      resourceAccessRules: []
      bypass: 'AzureServices'
      ipRules: []
      defaultAction: 'deny'
    }
    privateEndpoints: [
      'dfs'
    ]
  }
}

resource kvE 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: kvName
  scope: resourceGroup(rg.name)
}

resource stE 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: stDlName
  scope: rg
}

resource dbwE 'Microsoft.Databricks/workspaces@2023-09-15-preview' existing =
  if (databricksExists) {
    name: 'dbw-${prefixDbw}-01'
    scope: rgDbw
  }

resource synwE 'Microsoft.Synapse/workspaces@2021-06-01' existing = {
  name: 'synw-${prefixSynw}-01'
  scope: rgSynw

  resource sql 'sqlPools' existing = {
    name: 'sqlsynw01'
  }
}

module adfM 'modules/adf.bicep' = {
  scope: rgAdf
  name: 'data_factory'
  params: {
    name: 'adf-${prefixAdf}-01'
    location: location
    tags: config.tags
    rgDns: rg.name
    snetId: vnetM.outputs.snet['snet-pep'].id
    sqlName: sqlM.outputs.name
    sqlPass: kvE.getSecret('sqlpass')
    stId: resourceId(subscription().subscriptionId, rg.name, 'Microsoft.Storage/storageAccounts', stDlName)
    stName: stDlName
    accountKey: stE.listKeys().keys[0].value
    stDlName: stDl.outputs.name
    kvName: kvE.name
    stMonitorName: st.outputs.name
    dbwUrl: databricksExists ? dbwE.properties.workspaceUrl : ''
    dbwId: databricksExists ? dbwE.id : ''
    synapseConnectionString: synapseExists
      ? 'Data Source=tcp:${synwE.properties.connectivityEndpoints['sql']},1433;Initial Catalog=${synwE::sql.name}'
      : ''
  }
}

module rbacAdfStorage 'modules/rbac.bicep' = {
  scope: rg
  name: 'rbac_adf_storage'
  params: {
    principalId: adfM.outputs.principalId
    roles: [
      'Storage Blob Data Owner'
    ]
  }
}

module rbacSymwStorage 'modules/rbac.bicep' = {
  scope: rg
  name: 'rbac_synw_storage'
  params: {
    principalId: synwM.outputs.principalId
    roles: [
      'Storage Blob Data Owner'
    ]
  }
}

module rbacAdfKv 'modules/rbac.bicep' = {
  scope: rg
  name: 'rbac_adf_kv'
  params: {
    principalId: adfM.outputs.principalId
    roles: [
      'Key Vault Administrator'
    ]
  }
}

module dbw 'modules/dbw.bicep' = {
  scope: rgDbw
  name: 'dbw'
  params: {
    location: location
    name: 'dbw-${prefixDbw}-01'
    snetPepId: vnetM.outputs.snet['snet-pep'].id
    snetPrivateName: 'snet-dbw-private'
    snetPublicName: 'snet-dbw-public'
    vnetId: vnetM.outputs.id
    dnsRgName: rg.name
    adfObjectId: adfM.outputs.principalId
    privateEndpoints: [
      'browser_authentication'
      'databricks_ui_api'
    ]
  }
}

module synwM 'modules/synw.bicep' = {
  scope: rgSynw
  name: 'synapse'
  params: {
    computeSnetId: vnetM.outputs.snet['snet-mgmt'].id
    dnsRgName: rg.name
    location: location
    name: 'synw-${prefixSynw}-01'
    privateEndpoints: [
      'dev'
      'sqlondemand'
      'sql'
    ]
    snetPepId: vnetM.outputs.snet['snet-pep'].id
    stUrl: stDl.outputs.urlDfs
    tags: config.tags
    sqlPass: kvE.getSecret('sqlpass')
    adfObjectId: adfM.outputs.principalId
    myIp: myIp
  }
}

output mIdPrincipal string = adfM.outputs.principalId
output grpObjectId string = sqlGroup.objectId
