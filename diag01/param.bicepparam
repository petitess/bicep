using 'main.bicep'

param env = toLower(param.tags.Environment)
param param = {
  location: 'SwedenCentral'
  locationAlt: 'WestEurope'
  tags: {
    Application: 'Infra'
    Environment: 'Dev'
  }
}
