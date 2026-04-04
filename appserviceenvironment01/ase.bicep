param name string
param snetId string
param location string
param vnetId string

resource ase 'Microsoft.Web/hostingEnvironments@2025-05-01' = {
  name: name
  location: location
  kind: 'ASEV3'
  properties: {
    clusterSettings: [
      {
        name: 'DisableTls1.0'
        value: '1'
      }
    ]
    virtualNetwork: {
      id: snetId
    }
    networkingConfiguration: {
      allowNewPrivateEndpointConnections: true
      properties: {}
    }
  }
}

resource dns 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: 'appserviceenvironment.net'
  location: 'global'

  resource a 'A' = {
    name: '*'
    properties: {
      ttl: 3600
      aRecords: [
        {
          ipv4Address: '10.10.1.185'
        }
      ]
    }
  }
  resource aa 'A' = {
    name: '*.scm'
    properties: {
      ttl: 3600
      aRecords: [
        {
          ipv4Address: '10.10.1.185'
        }
      ]
    }
  }
  resource aaa 'A' = {
    name: '@'
    properties: {
      ttl: 3600
      aRecords: [
        {
          ipv4Address: '10.10.1.185'
        }
      ]
    }
  }
  @onlyIfNotExists()
  resource link 'virtualNetworkLinks' = {
    name: 'link-ase'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: vnetId
      }
    }
  }
}

output id string = ase.id
output ase object = ase
