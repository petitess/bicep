targetScope = 'resourceGroup'

param name string
param location string

var tags = resourceGroup().tags

resource nw 'Microsoft.Network/networkWatchers@2021-08-01' = {
  name: name
  location: location
  tags: tags
  properties:{}
}



