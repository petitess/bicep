targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags

resource nw 'Microsoft.Network/networkWatchers@2022-07-01' = {
  name: name
  location: location
  tags: tags
}

output id string = nw.id
output name string = nw.name
