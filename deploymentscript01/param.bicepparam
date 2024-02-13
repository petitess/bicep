using 'main.bicep'

param env = 'dev'
param appGroups = [
  'app-itglue-dev'
  'app-esign-dev'
]
param identities = [
  {
    name: 'id-system-01'
    groupName: 'grp-rbac-app-itglue-${env}'
  }
  {
    name: 'id-product-01'
    groupName: 'grp-rbac-app-itglue-${env}'
  }
  {
    name: 'id-network-01'
    groupName: 'grp-rbac-app-esign-${env}'
  }
]
param param = {
  location: 'swedencentral'
  tags: {
    Environment: 'dev'
  }
}
