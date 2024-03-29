using 'main.bicep'

param config = {
  location: {
    name: 'swedencentral'
    affix: 'sc'
  }
  company: {
    name: 'ZXC'
    affix: 'zxc'
  }
  environment: {
    name: 'development'
    affix: 'dev'
  }
}

param dns = [
  {
    name: 'domain.biz'
    Arecords: [
      {
        name: 'pool'
        properites: {
          TLL: 900
          ARecords: [
            {
              ipv4Address: '1.1.1.1'
            }
            {
              ipv4Address: '8.8.8.8'
            }
          ]
        }
      }
      {
        name: 'file'
        properites: {
          TLL: 900
          ARecords: [
            {
              ipv4Address: '20.234.2.5'
            }
          ]
        }
      }
    ]
    CNAMES: [
      {
        name: 'enterpriseenrollment'
        properties: {
          TLL: 3600
          CNAMERecord: {
            cname: 'EnterpriseEnrollment-s.manage.microsoft.com'
          }
        }
      }
      {
        name: 'enterpriseregistration'
        properties: {
          TLL: 3600
          CNAMERecord: {
            cname: 'EnterpriseRegistration.windows.net'
          }
        }
      }
    ]
    TXTS: [
      {
        name: '@'
        properties: {
          TLL: 900
          TXTRecords: [
            {
              value: [
                'pardot945873=03xxxxxxxxxxxxxxeeeeeeeec5fd53c6ef8f2bfa1b5303e7'
              ]
            }
            {
              value: [
                'facebook-domain-verification=xxxxxxxxxxxxxxxxxgsrv7'
              ]
            }
          ]
        }
      }
    ]
    MXS: [
      {
        name: 'molndal'
        properties: {
          TLL: 900
          MXRecords: [
            {
              exchange: 'company.protection.outlook.com.'
              preference: 10
            }
            {
              exchange: 'test.protection.outlook.com.'
              preference: 10
            }
          ]
        }
      }
    ]
    SRVS: [
      {
        name: '_sipfederationtls._tcp'
        properties: {
          TTL: 3600
          SRVRecords: [
            {
              port: 5061
              priority: 100
              target: 'sip.online.lyc.com'
              weight: 1
            }
          ]
        }
      }
    ]
  }
  {
    name: 'domain.org'
    Arecords: [
      {
        name: 'pool'
        properites: {
          TLL: 900
          ARecords: [
            {
              ipv4Address: '1.1.1.1'
            }
            {
              ipv4Address: '8.8.8.8'
            }
          ]
        }
      }
      {
        name: 'file'
        properites: {
          TLL: 900
          ARecords: [
            {
              ipv4Address: '20.234.2.5'
            }
          ]
        }
      }
      {
        name: 'ftp'
        properites: {
          TLL: 900
          ARecords: [
            {
              ipv4Address: '20.134.2.5'
            }
          ]
        }
      }
    ]
    CNAMES: [
      {
        name: 'enterpriseenrollment'
        properties: {
          TLL: 3600
          CNAMERecord: {
            cname: 'EnterpriseEnrollment-s.manage.microsoft.com'
          }
        }
      }
      {
        name: 'enterpriseregistration'
        properties: {
          TLL: 3600
          CNAMERecord: {
            cname: 'EnterpriseRegistration.windows.net'
          }
        }
      }
    ]
    TXTS: [
      {
        name: '@'
        properties: {
          TLL: 900
          TXTRecords: [
            {
              value: [
                'pardot945873=03xxxxxxxxxxxxxxeeeeeeeec5fd53c6ef8f2bfa1b5303e7'
              ]
            }
            {
              value: [
                'facebook-domain-verification=xxxxxxxxxxxxxxxxxgsrv7'
              ]
            }
          ]
        }
      }
    ]
    MXS: [
      {
        name: 'molndal'
        properties: {
          TLL: 900
          MXRecords: [
            {
              exchange: 'company.protection.outlook.com.'
              preference: 10
            }
            {
              exchange: 'test.protection.outlook.com.'
              preference: 10
            }
          ]
        }
      }
    ]
    SRVS: [
      {
        name: '_sipfederationtls._tcp'
        properties: {
          TTL: 3600
          SRVRecords: [
            {
              port: 5061
              priority: 100
              target: 'sip.online.lyc.com'
              weight: 1
            }
          ]
        }
      }
    ]
  }
]
