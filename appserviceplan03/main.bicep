targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var env = toLower(param.tags.Environment)

resource rgitglue 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: param.location
  tags: union(param.tags, {
      Application: 'ITglue Integration'
    })
  name: 'rg-app-int-${env}-01'
}

module log 'log.bicep' = {
  name: 'module-${affix}-log'
  scope: rgitglue
  params: {
    name: 'log-${affix}-01'
    location: param.location
    sku: param.log.sku
    retentionInDays: param.log.retention
    solutions: []//param.log.solutions
    events: param.log.events
  }
}

module appin 'appinsight.bicep' = {
  scope: rgitglue
  name: 'module-${affix}-appinsight'
  params: {
    name: 'appi-${affix}-01'
    location: param.location
    WorkspaceResourceId: log.outputs.id
    webtests: param.webtests
  }
}

module kvint 'kvint.bicep' = {
  name: 'module-${env}-kvint'
  scope: rgitglue
  params: {
    name: param.itglueint.kvname
    location: param.location
    param: param
  }
}

module appitglueint 'appitglueint.bicep' = {
  scope: rgitglue
  name: 'module-${affix}-appint'
  params: {
    appiconstring: appin.outputs.ConnectionString
    KeyVaultUrl: 'https://${param.itglueint.kvname}${environment().suffixes.keyvaultDns}/'
    location: param.location
    env: env
    keyvaultadmin: param.id.keyvaultadmin
  }
}

module sql 'sqlint.bicep' = {
  scope: rgitglue
  name: 'module-${affix}-sqlint'
  params: {
    location: param.location
    env: env
    sqlpassword: kvint.outputs.pass
    groupsid: param.id.group.sid
    groupname: param.id.group.name
    kvname: kvint.outputs.name
  }
}
