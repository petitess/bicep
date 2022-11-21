targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var env = toLower(param.tags.Environment)

// resource rginfra 'Microsoft.Resources/resourceGroups@2021-04-01' = {
//   location: param.location
//   tags: param.tags
//   name: 'rgx-${affix}-sc-01'
// }

resource rglogic 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: param.location
  tags: union(param.tags, {
      Application: 'AD Password Expiration'
    })
  name: 'rgx-logic-${env}-01'
}



module logic 'logic.bicep' = {
  scope: rglogic
  name: 'module-logic'
  params: {
    location: param.locationAlt
  }
}
