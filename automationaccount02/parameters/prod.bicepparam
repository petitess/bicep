using '../main.bicep'

param location = 'westeurope'

param tags = {
  Application: 'Infra'
  Environment: 'Prod'
}

param webtests = [
  {
    name: 'google'
    url: 'https://google.com'
    actionGroupGtm: true
  }
]
