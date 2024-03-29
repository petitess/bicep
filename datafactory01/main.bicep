targetScope = 'subscription'

param config object
param environment string
param location string = deployment().location
param vnet object
param kv object

var prefix = toLower('${config.product}-sys-${environment}-${config.location}')
var prefixAdf = toLower('${config.product}-adf-${environment}-${config.location}')
var kvName = 'kv-${prefix}-01'
var myIp = '188.150.99.111'
var stDlName = toLower('st${config.product}datalake${environment}01')
var sqlGroup = {
  name: 'grp-infra-contributor'
  objectId: 'xxxx-69df-4158-8861-f57e8261c2c1'
}

var domains = [
  'privatelink${az.environment().suffixes.sqlServerHostname}'
  'privatelink.datafactory.azure.net'
  'privatelink.vaultcore.azure.net'
  'privatelink.blob.${az.environment().suffixes.storage}'
  'privatelink.dfs.${az.environment().suffixes.storage}'
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

module sqlz 'modules/sql.bicep' = {
  scope: rgAdf
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
    mpepName: '${stDlName}.0e15d2dd-5a27-4d1a-b12d-f11147ffe31e' //can be approved just once
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
    mpepName: ''
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
  name: 'kv-infra-sys-dev-we-01'
  scope: resourceGroup('rg-infra-sys-dev-we-01')
}

resource stE 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: stDlName
  scope: rg
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
    sqlPass: kvE.getSecret('secret01')
    stId: resourceId(subscription().subscriptionId, rg.name, 'Microsoft.Storage/storageAccounts', stDlName)
    stName: stDlName
    accountKey: stE.listKeys().keys[0].value
    repoconfiguration: {
      //git configuration doesnt appear in the portal and removes existing git config
      //git configuration conflicts with bicep configuration. can't have both
      type: 'FactoryVSTSConfiguration'
      accountname: 'xxxse'
      repositoryname: 'xxx-labb'
      projectname: 'Infrastruktur'
      collaborationbranch: 'datafactory'
      rootfolder: '/'
      tenantId: tenant().tenantId
      disablePublish: false
    }
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

output mIdPrincipal string = adfM.outputs.principalId
output grpObjectId string = sqlGroup.objectId
