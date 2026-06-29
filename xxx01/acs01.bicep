param env string
var location = 'global'

resource acs 'Microsoft.Communication/communicationServices@2026-03-18' = {
  name: 'acs-${env}-abcd-01'
  location: location
  properties: {
    dataLocation: 'Europe'
    linkedDomains: env == 'prod'
      ? [
          aecsd.id
          aecsdAbcd.id
        ]
      : [
          aecsd.id
        ]
  }
}
resource aecs 'Microsoft.Communication/emailServices@2026-03-18' = {
  name: 'aecs-${env}-abcd-01'
  location: location
  properties: {
    dataLocation: 'Europe'
  }
}
@onlyIfNotExists()
resource aecsd 'Microsoft.Communication/emailServices/domains@2026-03-18' = {
  name: 'AzureManagedDomain'
  location: location
  parent: aecs
  properties: {
    domainManagement: 'AzureManaged'
  }
}
@onlyIfNotExists()
resource aecsdAbcd 'Microsoft.Communication/emailServices/domains@2026-03-18' = if (env == 'prod') {
  name: 'abcd.se'
  location: location
  parent: aecs
  properties: {
    domainManagement: 'CustomerManaged'
  }
}
@onlyIfNotExists()
resource aecsdAbcdExtra 'Microsoft.Communication/emailServices/domains/senderUsernames@2026-03-18' = if (env == 'prod') {
  name: 'DoNotReplyInt'
  parent: aecsdAbcd
  properties: {
    username: 'DoNotReplyInt'
    displayName: 'Abcd Integration'
  }
}
