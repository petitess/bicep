using '../main.bicep'

param environment = 'dev'
param config = {
  product: 'infra'
  location: 'we'
  tags: {
    Product: 'Common Infrastructure'
    Environment: 'Development'
    CostCenter: '9100'
  }
  agw: {
    privateIPAddress: '10.100.6.10'
    sslCertificates: [
      'xxxsolutions-com'
      'xxx-se'
      'skillxxx-io'
      'xxx-onsite-se'
    ]
    sites: [
      {
        name: 'access-app'
        hostname: 'access-dev.xxxsolutions.com'
        sslCertificate: 'xxxsolutions-com'
        probePath: '/health'
        pickHostNameFromBackendAddress: false
        privateListener: false
        deleteResponseHeaders: true
        backendAddresses: [
          {
            fqdn: 'app-access-fhl-dev-we-01.azurewebsites.net'
          }
        ]
        waf: {
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-932-APPLICATION-ATTACK-RCE'
              rules: [
                {
                  ruleId: '932100'
                  state: 'Disabled'
                }
                {
                  ruleId: '932105'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
              rules: [
                {
                  ruleId: '942200'
                  state: 'Disabled'
                }
                {
                  ruleId: '942260'
                  state: 'Disabled'
                }
                {
                  ruleId: '942340'
                  state: 'Disabled'
                }
                {
                  ruleId: '942370'
                  state: 'Disabled'
                }
                {
                  ruleId: '942430'
                  state: 'Disabled'
                }
                {
                  ruleId: '942440'
                  state: 'Disabled'
                }
                {
                  ruleId: '942450'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
      {
        name: 'portal-xxxsolutions-app'
        hostname: 'portal-utv.xxxsolutions.com'
        sslCertificate: 'xxxsolutions-com'
        probePath: '/api/health'
        pickHostNameFromBackendAddress: false
        privateListener: false
        backendAddresses: [
          {
            fqdn: 'app-portal-kv7-dev-we-01.azurewebsites.net'
          }
        ]
        waf: {
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-920-PROTOCOL-ENFORCEMENT'
              rules: [
                {
                  ruleId: '920300'
                  state: 'Disabled'
                }
                {
                  ruleId: '920320'
                  state: 'Disabled'
                }
                {
                  ruleId: '920230'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-932-APPLICATION-ATTACK-RCE'
              rules: [
                {
                  ruleId: '932100'
                  state: 'Disabled'
                }
                {
                  ruleId: '932105'
                  state: 'Disabled'
                }
                {
                  ruleId: '932115'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
              rules: [
                {
                  ruleId: '942200'
                  state: 'Disabled'
                }
                {
                  ruleId: '942370'
                  state: 'Disabled'
                }
                {
                  ruleId: '942430'
                  state: 'Disabled'
                }
                {
                  ruleId: '942440'
                  state: 'Disabled'
                }
                {
                  ruleId: '942450'
                  state: 'Disabled'
                }
                {
                  ruleId: '942260'
                  state: 'Disabled'
                }
                {
                  ruleId: '942190'
                  state: 'Disabled'
                }
                {
                  ruleId: '942210'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-931-APPLICATION-ATTACK-RFI'
              rules: [
                {
                  ruleId: '931130'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
      {
        name: 'portal-xxxse-app'
        hostname: 'portal-utv.xxx.se'
        sslCertificate: 'xxx-se'
        probePath: '/api/health'
        pickHostNameFromBackendAddress: false
        privateListener: false
        backendAddresses: [
          {
            fqdn: 'app-portal-kv7-dev-we-01.azurewebsites.net'
          }
        ]
        waf: {
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-920-PROTOCOL-ENFORCEMENT'
              rules: [
                {
                  ruleId: '920300'
                  state: 'Disabled'
                }
                {
                  ruleId: '920320'
                  state: 'Disabled'
                }
                {
                  ruleId: '920230'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-932-APPLICATION-ATTACK-RCE'
              rules: [
                {
                  ruleId: '932100'
                  state: 'Disabled'
                }
                {
                  ruleId: '932115'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
              rules: [
                {
                  ruleId: '942200'
                  state: 'Disabled'
                }
                {
                  ruleId: '942370'
                  state: 'Disabled'
                }
                {
                  ruleId: '942430'
                  state: 'Disabled'
                }
                {
                  ruleId: '942440'
                  state: 'Disabled'
                }
                {
                  ruleId: '942450'
                  state: 'Disabled'
                }
                {
                  ruleId: '942260'
                  state: 'Disabled'
                }
                {
                  ruleId: '942190'
                  state: 'Disabled'
                }
                {
                  ruleId: '942210'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-931-APPLICATION-ATTACK-RFI'
              rules: [
                {
                  ruleId: '931130'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
      {
        name: 'course-xxxsolutions-app'
        hostname: 'course-utv.xxxsolutions.com'
        sslCertificate: 'xxxsolutions-com'
        probePath: '/health'
        pickHostNameFromBackendAddress: false
        privateListener: false
        backendAddresses: [
          {
            fqdn: 'app-learning-nsa-dev-we-01.azurewebsites.net'
          }
        ]
        waf: {
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-920-PROTOCOL-ENFORCEMENT'
              rules: [
                {
                  ruleId: '920300'
                  state: 'Disabled'
                }
                {
                  ruleId: '920240'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-932-APPLICATION-ATTACK-RCE'
              rules: [
                {
                  ruleId: '932100'
                  state: 'Disabled'
                }
                {
                  ruleId: '932105'
                  state: 'Disabled'
                }
                {
                  ruleId: '932115'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
              rules: [
                {
                  ruleId: '942100'
                  state: 'Disabled'
                }
                {
                  ruleId: '942110'
                  state: 'Disabled'
                }
                {
                  ruleId: '942130'
                  state: 'Disabled'
                }
                {
                  ruleId: '942200'
                  state: 'Disabled'
                }
                {
                  ruleId: '942210'
                  state: 'Disabled'
                }
                {
                  ruleId: '942260'
                  state: 'Disabled'
                }
                {
                  ruleId: '942330'
                  state: 'Disabled'
                }
                {
                  ruleId: '942340'
                  state: 'Disabled'
                }
                {
                  ruleId: '942370'
                  state: 'Disabled'
                }
                {
                  ruleId: '942380'
                  state: 'Disabled'
                }
                {
                  ruleId: '942400'
                  state: 'Disabled'
                }
                {
                  ruleId: '942430'
                  state: 'Disabled'
                }
                {
                  ruleId: '942440'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
      {
        name: 'course-xxxse-app'
        hostname: 'course-utv.xxx.se'
        sslCertificate: 'xxx-se'
        probePath: '/health'
        pickHostNameFromBackendAddress: false
        privateListener: false
        backendAddresses: [
          {
            fqdn: 'app-learning-nsa-dev-we-01.azurewebsites.net'
          }
        ]
        waf: {
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-920-PROTOCOL-ENFORCEMENT'
              rules: [
                {
                  ruleId: '920230'
                  state: 'Disabled'
                }
                {
                  ruleId: '920240'
                  state: 'Disabled'
                }
                {
                  ruleId: '920300'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-932-APPLICATION-ATTACK-RCE'
              rules: [
                {
                  ruleId: '932100'
                  state: 'Disabled'
                }
                {
                  ruleId: '932105'
                  state: 'Disabled'
                }
                {
                  ruleId: '932115'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
              rules: [
                {
                  ruleId: '942100'
                  state: 'Disabled'
                }
                {
                  ruleId: '942110'
                  state: 'Disabled'
                }
                {
                  ruleId: '942130'
                  state: 'Disabled'
                }
                {
                  ruleId: '942150'
                  state: 'Disabled'
                }
                {
                  ruleId: '942200'
                  state: 'Disabled'
                }
                {
                  ruleId: '942210'
                  state: 'Disabled'
                }
                {
                  ruleId: '942230'
                  state: 'Disabled'
                }
                {
                  ruleId: '942260'
                  state: 'Disabled'
                }
                {
                  ruleId: '942330'
                  state: 'Disabled'
                }
                {
                  ruleId: '942340'
                  state: 'Disabled'
                }
                {
                  ruleId: '942370'
                  state: 'Disabled'
                }
                {
                  ruleId: '942380'
                  state: 'Disabled'
                }
                {
                  ruleId: '942390'
                  state: 'Disabled'
                }
                {
                  ruleId: '942400'
                  state: 'Disabled'
                }
                {
                  ruleId: '942410'
                  state: 'Disabled'
                }
                {
                  ruleId: '942430'
                  state: 'Disabled'
                }
                {
                  ruleId: '942440'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
      {
        name: 'my-xxxsolutions-app'
        hostname: 'my-utv.xxxsolutions.com'
        sslCertificate: 'xxxsolutions-com'
        probePath: '/'
        pickHostNameFromBackendAddress: false
        privateListener: false
        backendAddresses: [
          {
            fqdn: 'app-learning-my-nsa-dev-we-01.azurewebsites.net'
          }
        ]
        waf: {
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-920-PROTOCOL-ENFORCEMENT'
              rules: [
                {
                  ruleId: '920300'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-931-APPLICATION-ATTACK-RFI'
              rules: [
                {
                  ruleId: '931130'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-932-APPLICATION-ATTACK-RCE'
              rules: [
                {
                  ruleId: '932100'
                  state: 'Disabled'
                }
                {
                  ruleId: '932105'
                  state: 'Disabled'
                }
                {
                  ruleId: '932110'
                  state: 'Disabled'
                }
                {
                  ruleId: '932115'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-941-APPLICATION-ATTACK-XSS'
              rules: [
                {
                  ruleId: '941100'
                  state: 'Disabled'
                }
                {
                  ruleId: '941110'
                  state: 'Disabled'
                }
                {
                  ruleId: '941120'
                  state: 'Disabled'
                }
                {
                  ruleId: '941150'
                  state: 'Disabled'
                }
                {
                  ruleId: '941160'
                  state: 'Disabled'
                }
                {
                  ruleId: '941320'
                  state: 'Disabled'
                }
                {
                  ruleId: '941330'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
              rules: [
                {
                  ruleId: '942130'
                  state: 'Disabled'
                }
                {
                  ruleId: '942150'
                  state: 'Disabled'
                }
                {
                  ruleId: '942200'
                  state: 'Disabled'
                }
                {
                  ruleId: '942310'
                  state: 'Disabled'
                }
                {
                  ruleId: '942330'
                  state: 'Disabled'
                }
                {
                  ruleId: '942340'
                  state: 'Disabled'
                }
                {
                  ruleId: '942370'
                  state: 'Disabled'
                }
                {
                  ruleId: '942410'
                  state: 'Disabled'
                }
                {
                  ruleId: '942430'
                  state: 'Disabled'
                }
                {
                  ruleId: '942260'
                  state: 'Disabled'
                }
                {
                  ruleId: '942440'
                  state: 'Disabled'
                }
                {
                  ruleId: '942450'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
      {
        name: 'my-xxxse-app'
        hostname: 'my-utv.xxx.se'
        sslCertificate: 'xxx-se'
        probePath: '/'
        pickHostNameFromBackendAddress: false
        privateListener: false
        backendAddresses: [
          {
            fqdn: 'app-learning-my-nsa-dev-we-01.azurewebsites.net'
          }
        ]
        waf: {
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-920-PROTOCOL-ENFORCEMENT'
              rules: [
                {
                  ruleId: '920300'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-931-APPLICATION-ATTACK-RFI'
              rules: [
                {
                  ruleId: '931130'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-932-APPLICATION-ATTACK-RCE'
              rules: [
                {
                  ruleId: '932100'
                  state: 'Disabled'
                }
                {
                  ruleId: '932105'
                  state: 'Disabled'
                }
                {
                  ruleId: '932110'
                  state: 'Disabled'
                }
                {
                  ruleId: '932115'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-941-APPLICATION-ATTACK-XSS'
              rules: [
                {
                  ruleId: '941100'
                  state: 'Disabled'
                }
                {
                  ruleId: '941110'
                  state: 'Disabled'
                }
                {
                  ruleId: '941120'
                  state: 'Disabled'
                }
                {
                  ruleId: '941150'
                  state: 'Disabled'
                }
                {
                  ruleId: '941160'
                  state: 'Disabled'
                }
                {
                  ruleId: '941320'
                  state: 'Disabled'
                }
                {
                  ruleId: '941330'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
              rules: [
                {
                  ruleId: '942130'
                  state: 'Disabled'
                }
                {
                  ruleId: '942150'
                  state: 'Disabled'
                }
                {
                  ruleId: '942200'
                  state: 'Disabled'
                }
                {
                  ruleId: '942310'
                  state: 'Disabled'
                }
                {
                  ruleId: '942330'
                  state: 'Disabled'
                }
                {
                  ruleId: '942340'
                  state: 'Disabled'
                }
                {
                  ruleId: '942370'
                  state: 'Disabled'
                }
                {
                  ruleId: '942410'
                  state: 'Disabled'
                }
                {
                  ruleId: '942430'
                  state: 'Disabled'
                }
                {
                  ruleId: '942260'
                  state: 'Disabled'
                }
                {
                  ruleId: '942440'
                  state: 'Disabled'
                }
                {
                  ruleId: '942450'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
      {
        name: 'auth-app'
        hostname: 'bea-stage.xxx.se'
        sslCertificate: 'xxx-se'
        probePath: '/'
        pickHostNameFromBackendAddress: false
        privateListener: false
        backendAddresses: [
          {
            fqdn: 'xxx-utv-auth-web.azurewebsites.net'
          }
        ]
        waf: {
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-932-APPLICATION-ATTACK-RCE'
              rules: [
                {
                  ruleId: '932100'
                  state: 'Disabled'
                }
                {
                  ruleId: '932105'
                  state: 'Disabled'
                }
                {
                  ruleId: '932115'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
              rules: [
                {
                  ruleId: '942430'
                  state: 'Disabled'
                }
                {
                  ruleId: '942440'
                  state: 'Disabled'
                }
                {
                  ruleId: '942450'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-920-PROTOCOL-ENFORCEMENT'
              rules: [
                {
                  ruleId: '920230'
                  state: 'Disabled'
                }
                {
                  ruleId: '920300'
                  state: 'Disabled'
                }
                {
                  ruleId: '920320'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-931-APPLICATION-ATTACK-RFI'
              rules: [
                {
                  ruleId: '931130'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
      {
        name: 'consent-app'
        hostname: 'consent-utv.xxxsolutions.com'
        sslCertificate: 'xxxsolutions-com'
        probePath: '/api/health'
        pickHostNameFromBackendAddress: false
        privateListener: false
        backendAddresses: [
          {
            fqdn: 'app-consent-api-dfm-dev-we-01.azurewebsites.net'
          }
        ]
        waf: {
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-932-APPLICATION-ATTACK-RCE'
              rules: [
                {
                  ruleId: '932100'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
              rules: [
                {
                  ruleId: '942430'
                  state: 'Disabled'
                }
                {
                  ruleId: '942440'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-920-PROTOCOL-ENFORCEMENT'
              rules: [
                {
                  ruleId: '920300'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
      {
        name: 'consent-xxxse-app'
        hostname: 'consent-utv.xxx.se'
        sslCertificate: 'xxx-se'
        probePath: '/api/health'
        pickHostNameFromBackendAddress: false
        privateListener: false
        backendAddresses: [
          {
            fqdn: 'app-consent-api-dfm-dev-we-01.azurewebsites.net'
          }
        ]
        waf: {
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-932-APPLICATION-ATTACK-RCE'
              rules: [
                {
                  ruleId: '932100'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
              rules: [
                {
                  ruleId: '942430'
                  state: 'Disabled'
                }
                {
                  ruleId: '942440'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-920-PROTOCOL-ENFORCEMENT'
              rules: [
                {
                  ruleId: '920300'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
      {
        name: 'pay-app'
        hostname: 'pay-utv.xxxsolutions.com'
        sslCertificate: 'xxxsolutions-com'
        probePath: '/api/health'
        pickHostNameFromBackendAddress: false
        privateListener: false
        backendAddresses: [
          {
            fqdn: 'app-invoicepayment-hbr-dev-we-01.azurewebsites.net'
          }
        ]
        waf: {
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-932-APPLICATION-ATTACK-RCE'
              rules: [
                {
                  ruleId: '932100'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
              rules: [
                {
                  ruleId: '942430'
                  state: 'Disabled'
                }
                {
                  ruleId: '942440'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
      {
        name: 'compliance-web'
        hostname: 'compliance-dev.xxx.se'
        sslCertificate: 'xxx-se'
        probePath: '/monitor'
        pickHostNameFromBackendAddress: false
        privateListener: false
        backendAddresses: [
          {
            fqdn: 'app-compliancetool-web-q2q-dev-we-01.azurewebsites.net'
          }
        ]
        waf: {
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-932-APPLICATION-ATTACK-RCE'
              rules: [
                {
                  ruleId: '932100'
                  state: 'Disabled'
                }
                {
                  ruleId: '932115'
                  state: 'Disabled'
                }
                {
                  ruleId: '932110'
                  state: 'Disabled'
                }
                {
                  ruleId: '932130'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-920-PROTOCOL-ENFORCEMENT'
              rules: [
                {
                  ruleId: '920300'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-941-APPLICATION-ATTACK-XSS'
              rules: [
                {
                  ruleId: '941320'
                  state: 'Disabled'
                }
                {
                  ruleId: '941160'
                  state: 'Disabled'
                }
                {
                  ruleId: '941110'
                  state: 'Disabled'
                }
                {
                  ruleId: '941100'
                  state: 'Disabled'
                }
                {
                  ruleId: '941130'
                  state: 'Disabled'
                }
                {
                  ruleId: '941170'
                  state: 'Disabled'
                }
                {
                  ruleId: '941340'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
              rules: [
                {
                  ruleId: '942410'
                  state: 'Disabled'
                }
                {
                  ruleId: '942430'
                  state: 'Disabled'
                }
                {
                  ruleId: '942440'
                  state: 'Disabled'
                }
                {
                  ruleId: '942450'
                  state: 'Disabled'
                }
                {
                  ruleId: '942130'
                  state: 'Disabled'
                }
                {
                  ruleId: '942140'
                  state: 'Disabled'
                }
                {
                  ruleId: '942150'
                  state: 'Disabled'
                }
                {
                  ruleId: '942190'
                  state: 'Disabled'
                }
                {
                  ruleId: '942370'
                  state: 'Disabled'
                }
                {
                  ruleId: '942200'
                  state: 'Disabled'
                }
                {
                  ruleId: '942260'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
      {
        name: 'compliance-webapp'
        hostname: 'compliance-dev.xxxsolutions.com'
        sslCertificate: 'xxxsolutions-com'
        probePath: '/api/health'
        pickHostNameFromBackendAddress: false
        privateListener: false
        backendAddresses: [
          {
            fqdn: 'app-compliancetool-view-q2q-dev-we-01.azurewebsites.net'
          }
        ]
        waf: {
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-932-APPLICATION-ATTACK-RCE'
              rules: [
                {
                  ruleId: '932100'
                  state: 'Disabled'
                }
                {
                  ruleId: '932115'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-920-PROTOCOL-ENFORCEMENT'
              rules: [
                {
                  ruleId: '920300'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
              rules: [
                {
                  ruleId: '942430'
                  state: 'Disabled'
                }
                {
                  ruleId: '942440'
                  state: 'Disabled'
                }
                {
                  ruleId: '942200'
                  state: 'Disabled'
                }
                {
                  ruleId: '942370'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
      {
        name: 'molli-app'
        hostname: 'm-utv.xxx.se'
        sslCertificate: 'xxx-se'
        probePath: '/'
        pickHostNameFromBackendAddress: false
        privateListener: false
        backendAddresses: [
          {
            fqdn: 'xxx-utv-molli-web.azurewebsites.net'
          }
        ]
        waf: {
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-920-PROTOCOL-ENFORCEMENT'
              rules: [
                {
                  ruleId: '920300'
                  state: 'Disabled'
                }
                {
                  ruleId: '920320'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-932-APPLICATION-ATTACK-RCE'
              rules: [
                {
                  ruleId: '932100'
                  state: 'Disabled'
                }
                {
                  ruleId: '932105'
                  state: 'Disabled'
                }
                {
                  ruleId: '932115'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-941-APPLICATION-ATTACK-XSS'
              rules: [
                {
                  ruleId: '941330'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
              rules: [
                {
                  ruleId: '942200'
                  state: 'Disabled'
                }
                {
                  ruleId: '942260'
                  state: 'Disabled'
                }
                {
                  ruleId: '942330'
                  state: 'Disabled'
                }
                {
                  ruleId: '942340'
                  state: 'Disabled'
                }
                {
                  ruleId: '942370'
                  state: 'Disabled'
                }
                {
                  ruleId: '942430'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
      {
        name: 'deliverycontract-web'
        hostname: 'deliverycontract-dev.xxxsolutions.com'
        sslCertificate: 'xxxsolutions-com'
        probePath: '/healthcheck'
        pickHostNameFromBackendAddress: false
        privateListener: false
        backendAddresses: [
          {
            fqdn: 'app-deliverycontract-iry-dev-we-01.azurewebsites.net'
          }
        ]
        waf: {
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
              rules: [
                {
                  ruleId: '942200'
                  state: 'Disabled'
                }
                {
                  ruleId: '942370'
                  state: 'Disabled'
                }
                {
                  ruleId: '942330'
                  state: 'Disabled'
                }
                {
                  ruleId: '942430'
                  state: 'Disabled'
                }
                {
                  ruleId: '942340'
                  state: 'Disabled'
                }
                {
                  ruleId: '942260'
                  state: 'Disabled'
                }
                {
                  ruleId: '942130'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-932-APPLICATION-ATTACK-RCE'
              rules: [
                {
                  ruleId: '932100'
                  state: 'Disabled'
                }
                {
                  ruleId: '932115'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-941-APPLICATION-ATTACK-XSS'
              rules: [
                {
                  ruleId: '941320'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-933-APPLICATION-ATTACK-PHP'
              rules: [
                {
                  ruleId: '933210'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
      {
        name: 'prolog-web'
        hostname: 'prolog-utv.xxx.se'
        sslCertificate: 'xxx-se'
        probePath: '/'
        pickHostNameFromBackendAddress: false
        privateListener: false
        backendAddresses: [
          {
            fqdn: 'prologutv-web.azurewebsites.net'
          }
        ]
        waf: {
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
              rules: [
                {
                  ruleId: '942200'
                  state: 'Disabled'
                }
                {
                  ruleId: '942370'
                  state: 'Disabled'
                }
                {
                  ruleId: '942430'
                  state: 'Disabled'
                }
                {
                  ruleId: '942440'
                  state: 'Disabled'
                }
                {
                  ruleId: '942450'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
      {
        name: 'prolog-web-dev'
        hostname: 'prolog-dev.xxx.se'
        sslCertificate: 'xxx-se'
        probePath: '/'
        pickHostNameFromBackendAddress: false
        privateListener: false
        backendAddresses: [
          {
            fqdn: 'app-standards-prolog-vrl-dev-we-01.azurewebsites.net'
          }
        ]
        waf: {
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
              rules: [
                {
                  ruleId: '942200'
                  state: 'Disabled'
                }
                {
                  ruleId: '942370'
                  state: 'Disabled'
                }
                {
                  ruleId: '942430'
                  state: 'Disabled'
                }
                {
                  ruleId: '942440'
                  state: 'Disabled'
                }
                {
                  ruleId: '942450'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
      {
        name: 'skillxxx-webapp'
        hostname: 'app-dev.skillxxx.io'
        sslCertificate: 'skillxxx-io'
        probePath: '/health'
        pickHostNameFromBackendAddress: false
        privateListener: false
        backendAddresses: [
          {
            fqdn: 'app-skillxxx-web-e5v-dev-we-01.azurewebsites.net'
          }
        ]
        waf: {
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-920-PROTOCOL-ENFORCEMENT'
              rules: [
                {
                  ruleId: '920300'
                  state: 'Disabled'
                }
                {
                  ruleId: '920320'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-932-APPLICATION-ATTACK-RCE'
              rules: [
                {
                  ruleId: '932100'
                  state: 'Disabled'
                }
                {
                  ruleId: '932115'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
              rules: [
                {
                  ruleId: '942110'
                  state: 'Disabled'
                }
                {
                  ruleId: '942430'
                  state: 'Disabled'
                }
                {
                  ruleId: '942440'
                  state: 'Disabled'
                }
                {
                  ruleId: '942190'
                  state: 'Disabled'
                }
                {
                  ruleId: '942200'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-930-APPLICATION-ATTACK-LFI'
              rules: [
                {
                  ruleId: '930120'
                  state: 'Disabled'
                }
                {
                  ruleId: '930130'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
      {
        name: 'skillxxx-st'
        hostname: 'storage-dev.skillxxx.io'
        backendSettingsProtocol: 'Http'
        sslCertificate: 'skillxxx-io'
        probePath: '/healthcheck/?comp=list'
        pickHostNameFromBackendAddress: false
        privateListener: false
        backendAddresses: [
          {
            fqdn: 'stsncommone5vdevwe01.privatelink.blob.core.windows.net'
          }
        ]
        waf: {
          maxRequestBodySizeInKb: 2048
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-930-APPLICATION-ATTACK-LFI'
              rules: [
                {
                  ruleId: '930110'
                  state: 'Disabled'
                }
                {
                  ruleId: '930100'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
      {
        name: 'projectstaffing-st'
        hostname: 'ps-storage-dev.xxxsolutions.com'
        backendSettingsProtocol: 'Http'
        sslCertificate: 'xxxsolutions-com'
        probePath: '/healthcheck/?comp=list'
        pickHostNameFromBackendAddress: false
        privateListener: false
        backendAddresses: [
          {
            fqdn: 'stpstaffinghzhdevwe01.privatelink.blob.core.windows.net'
          }
        ]
        waf: {
          maxRequestBodySizeInKb: 2048
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-930-APPLICATION-ATTACK-LFI'
              rules: [
                {
                  ruleId: '930110'
                  state: 'Disabled'
                }
                {
                  ruleId: '930100'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
      {
        name: 'compliancetool-st'
        hostname: 'ct-storage-dev.xxxsolutions.com'
        backendSettingsProtocol: 'Http'
        sslCertificate: 'xxxsolutions-com'
        probePath: '/healthcheck/?comp=list'
        pickHostNameFromBackendAddress: false
        privateListener: false
        backendAddresses: [
          {
            fqdn: 'stctq2qdevwe01.privatelink.blob.core.windows.net'
          }
        ]
        waf: {
          maxRequestBodySizeInKb: 2048
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-930-APPLICATION-ATTACK-LFI'
              rules: [
                {
                  ruleId: '930110'
                  state: 'Disabled'
                }
                {
                  ruleId: '930100'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
      {
        name: 'learning-admin-xxxsolutions-app'
        hostname: 'academy-dev.xxxsolutions.com'
        sslCertificate: 'xxxsolutions-com'
        probePath: '/health'
        pickHostNameFromBackendAddress: false
        privateListener: false
        backendAddresses: [
          {
            fqdn: 'app-learning-admin-nsa-dev-we-01.azurewebsites.net'
          }
        ]
        waf: {
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-920-PROTOCOL-ENFORCEMENT'
              rules: [
                {
                  ruleId: '920300'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-931-APPLICATION-ATTACK-RFI'
              rules: [
                {
                  ruleId: '931130'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-932-APPLICATION-ATTACK-RCE'
              rules: [
                {
                  ruleId: '932100'
                  state: 'Disabled'
                }
                {
                  ruleId: '932105'
                  state: 'Disabled'
                }
                {
                  ruleId: '932110'
                  state: 'Disabled'
                }
                {
                  ruleId: '932115'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
              rules: [
                {
                  ruleId: '942190'
                  state: 'Disabled'
                }
                {
                  ruleId: '942200'
                  state: 'Disabled'
                }
                {
                  ruleId: '942260'
                  state: 'Disabled'
                }
                {
                  ruleId: '942330'
                  state: 'Disabled'
                }
                {
                  ruleId: '942340'
                  state: 'Disabled'
                }
                {
                  ruleId: '942370'
                  state: 'Disabled'
                }
                {
                  ruleId: '942430'
                  state: 'Disabled'
                }
                {
                  ruleId: '942440'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
      {
        name: 'learning-admin-xxxse-app'
        hostname: 'academy-dev.xxx.se'
        sslCertificate: 'xxx-se'
        probePath: '/health'
        pickHostNameFromBackendAddress: false
        privateListener: false
        backendAddresses: [
          {
            fqdn: 'app-learning-admin-nsa-dev-we-01.azurewebsites.net'
          }
        ]
        waf: {
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-920-PROTOCOL-ENFORCEMENT'
              rules: [
                {
                  ruleId: '920300'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-931-APPLICATION-ATTACK-RFI'
              rules: [
                {
                  ruleId: '931130'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-932-APPLICATION-ATTACK-RCE'
              rules: [
                {
                  ruleId: '932100'
                  state: 'Disabled'
                }
                {
                  ruleId: '932105'
                  state: 'Disabled'
                }
                {
                  ruleId: '932110'
                  state: 'Disabled'
                }
                {
                  ruleId: '932115'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
              rules: [
                {
                  ruleId: '942190'
                  state: 'Disabled'
                }
                {
                  ruleId: '942200'
                  state: 'Disabled'
                }
                {
                  ruleId: '942260'
                  state: 'Disabled'
                }
                {
                  ruleId: '942330'
                  state: 'Disabled'
                }
                {
                  ruleId: '942340'
                  state: 'Disabled'
                }
                {
                  ruleId: '942370'
                  state: 'Disabled'
                }
                {
                  ruleId: '942430'
                  state: 'Disabled'
                }
                {
                  ruleId: '942440'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
      {
        name: 'projectstaffing-app'
        hostname: 'projectstaffing-dev.xxxsolutions.com'
        sslCertificate: 'xxxsolutions-com'
        probePath: '/health'
        pickHostNameFromBackendAddress: false
        privateListener: false
        backendAddresses: [
          {
            fqdn: 'app-projectstaffing-hzh-dev-we-01.azurewebsites.net'
          }
        ]
        waf: {
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-920-PROTOCOL-ENFORCEMENT'
              rules: [
                {
                  ruleId: '920300'
                  state: 'Disabled'
                }
                {
                  ruleId: '920320'
                  state: 'Disabled'
                }
              ]
            }

            {
              ruleGroupName: 'REQUEST-932-APPLICATION-ATTACK-RCE'
              rules: [
                {
                  ruleId: '932100'
                  state: 'Disabled'
                }
                {
                  ruleId: '932110'
                  state: 'Disabled'
                }
                {
                  ruleId: '932115'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
              rules: [
                {
                  ruleId: '942190'
                  state: 'Disabled'
                }
                {
                  ruleId: '942430'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
      {
        name: 'extapi-app'
        hostname: 'api-dev.xxxsolutions.com'
        sslCertificate: 'xxxsolutions-com'
        probePath: '/'
        pickHostNameFromBackendAddress: true
        privateListener: false
        pathBased: true
      }
      {
        name: 'webhooks-app'
        hostname: 'webhooks-dev.xxxsolutions.com'
        sslCertificate: 'xxxsolutions-com'
        probePath: '/'
        pickHostNameFromBackendAddress: true
        privateListener: false
        pathBased: true
      }
      {
        name: 'extapi-app-legacy'
        hostname: 'api-dev.xxx.se'
        sslCertificate: 'xxx-se'
        probePath: '/'
        pickHostNameFromBackendAddress: false
        privateListener: false
        pathBased: true
      }
      {
        name: 'standard-app'
        hostname: 'standard-dev.xxx.se'
        sslCertificate: 'xxx-se'
        probePath: '/'
        pickHostNameFromBackendAddress: false
        privateListener: false
        backendAddresses: [
          {
            fqdn: 'app-standards-standard-vrl-dev-we-01.azurewebsites.net'
          }
        ]
        waf: {
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
              rules: [
                {
                  ruleId: '942200'
                  state: 'Disabled'
                }
                {
                  ruleId: '942370'
                  state: 'Disabled'
                }
                {
                  ruleId: '942430'
                  state: 'Disabled'
                }
                {
                  ruleId: '942440'
                  state: 'Disabled'
                }
                {
                  ruleId: '942450'
                  state: 'Disabled'
                }
                {
                  ruleId: '942340'
                  state: 'Disabled'
                }
                {
                  ruleId: '942260'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
    ]
    pathRules: [
      {
        name: 'oauth'
        site: 'extapi-app'
        probePath: '/d923a467-48cc-4b99-96ce-1a312ce4a1e3/b2c_1a_ClientCredentialsFlow/v2.0/.well-known/openid-configuration'
        pickHostNameFromBackendAddress: true
        paths: [
          '/oauth2/v2.0/token'
        ]
        backendAddresses: [
          {
            fqdn: 'login-utv.xxxsolutions.com'
          }
        ]
        rewriteRuleSet: {
          actionSet: {
            urlConfiguration: {
              modifiedPath: '/xxxauthutv.onmicrosoft.com/B2C_1A_ClientCredentialsFlow/oauth2/v2.0/token'
              modifiedQueryString: '?scope=https%3A%2F%2Fxxxauthutv.onmicrosoft.com%2Fapi%2F.default'
              reroute: false
            }
          }
        }
        waf: {
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-931-APPLICATION-ATTACK-RFI'
              rules: [
                {
                  ruleId: '931130'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
      {
        name: 'projectstaffing'
        site: 'extapi-app'
        probePath: '/health'
        pickHostNameFromBackendAddress: true
        overrideBackendPath: '/'
        paths: [
          '/projectstaffing/*'
        ]
        backendAddresses: [
          {
            fqdn: 'app-projectstaffing-extapi-hzh-dev-we-01.azurewebsites.net'
          }
        ]
      }
      {
        name: 'access'
        site: 'extapi-app'
        probePath: '/health'
        pickHostNameFromBackendAddress: false
        overrideBackendPath: '/'
        paths: [
          '/api/access/*'
        ]
        backendAddresses: [
          {
            fqdn: 'app-access-extapi-api-fhl-dev-we-01.azurewebsites.net'
          }
        ]
        waf: {
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-920-PROTOCOL-ENFORCEMENT'
              rules: [
                {
                  ruleId: '920320'
                  state: 'Disabled'
                }
                {
                  ruleId: '920300'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
              rules: [
                {
                  ruleId: '942430'
                  state: 'Disabled'
                }
                {
                  ruleId: '942440'
                  state: 'Disabled'
                }
                {
                  ruleId: '942450'
                  state: 'Disabled'
                }
                {
                  ruleId: '942210'
                  state: 'Disabled'
                }
                {
                  ruleId: '942110'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-932-APPLICATION-ATTACK-RCE'
              rules: [
                {
                  ruleId: '932105'
                  state: 'Disabled'
                }
                {
                  ruleId: '932115'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
      {
        name: 'access-v1'
        site: 'extapi-app-legacy'
        probePath: '/health'
        pickHostNameFromBackendAddress: false
        overrideBackendPath: '/'
        paths: [
          '/api/access/*'
        ]
        backendAddresses: [
          {
            fqdn: 'app-access-extapi-api-fhl-dev-we-01.azurewebsites.net'
          }
        ]
        waf: {
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-920-PROTOCOL-ENFORCEMENT'
              rules: [
                {
                  ruleId: '920320'
                  state: 'Disabled'
                }
                {
                  ruleId: '920300'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
              rules: [
                {
                  ruleId: '942430'
                  state: 'Disabled'
                }
                {
                  ruleId: '942440'
                  state: 'Disabled'
                }
                {
                  ruleId: '942450'
                  state: 'Disabled'
                }
                {
                  ruleId: '942210'
                  state: 'Disabled'
                }
                {
                  ruleId: '942110'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-932-APPLICATION-ATTACK-RCE'
              rules: [
                {
                  ruleId: '932105'
                  state: 'Disabled'
                }
                {
                  ruleId: '932115'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
      {
        name: 'access-v1-webservice'
        site: 'extapi-app-legacy'
        probePath: '/'
        pickHostNameFromBackendAddress: false
        overrideBackendPath: '/'
        paths: [
          '/*'
        ]
        backendAddresses: [
          {
            fqdn: 'xxx-utv-dataapi.azurewebsites.net'
          }
        ]
        waf: {
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-920-PROTOCOL-ENFORCEMENT'
              rules: [
                {
                  ruleId: '920320'
                  state: 'Disabled'
                }
                {
                  ruleId: '920300'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
              rules: [
                {
                  ruleId: '942430'
                  state: 'Disabled'
                }
                {
                  ruleId: '942440'
                  state: 'Disabled'
                }
                {
                  ruleId: '942450'
                  state: 'Disabled'
                }
                {
                  ruleId: '942210'
                  state: 'Disabled'
                }
                {
                  ruleId: '942110'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-932-APPLICATION-ATTACK-RCE'
              rules: [
                {
                  ruleId: '932105'
                  state: 'Disabled'
                }
                {
                  ruleId: '932115'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
      {
        name: 'monitor-bot-messages'
        site: 'webhooks-app'
        probePath: '/'
        pickHostNameFromBackendAddress: true
        overrideBackendPath: '/api/messages'
        paths: [
          '/monitor/bot/messages'
        ]
        backendAddresses: [
          {
            fqdn: 'func-monitor-bot-fzz-dev-we-01.azurewebsites.net'
          }
        ]
        waf: {
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-931-APPLICATION-ATTACK-RFI'
              rules: [
                {
                  ruleId: '931130'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-941-APPLICATION-ATTACK-XSS'
              rules: [
                {
                  ruleId: '941320'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
              rules: [
                {
                  ruleId: '942130'
                  state: 'Disabled'
                }
              ]
            }
          ]
          customRules: []
        }
      }
      {
        name: 'monitor-bot-phonecallbacks'
        site: 'webhooks-app'
        probePath: '/'
        pickHostNameFromBackendAddress: true
        overrideBackendPath: '/api/phonecallbacks'
        paths: [
          '/monitor/bot/phonecallbacks'
        ]
        backendAddresses: [
          {
            fqdn: 'func-monitor-bot-fzz-dev-we-01.azurewebsites.net'
          }
        ]
      }
    ]
  }
  vnet: {
    addressPrefixes: [
      '10.100.6.0/24'
      '10.100.10.0/24'
    ]
    subnets: [
      {
        name: 'snet-agw'
        addressPrefix: '10.100.6.0/24'
        serviceEndpoints: [
          {
            service: 'Microsoft.KeyVault'
          }
        ]
        routes: [
          {
            name: 'udr-private-a'
            properties: {
              addressPrefix: '10.0.0.0/8'
              nextHopType: 'VirtualAppliance'
              nextHopIpAddress: '10.100.9.4'
            }
          }
          {
            name: 'udr-private-b'
            properties: {
              addressPrefix: '172.16.0.0/12'
              nextHopType: 'VirtualAppliance'
              nextHopIpAddress: '10.100.9.4'
            }
          }
          {
            name: 'udr-private-c'
            properties: {
              addressPrefix: '192.168.0.0/16'
              nextHopType: 'VirtualAppliance'
              nextHopIpAddress: '10.100.9.4'
            }
          }
        ]
        rules: [
          {
            name: 'nsgsr-allow-gatewaymanager-inbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: 'GatewayManager'
              sourcePortRange: '*'
              destixxxAddressPrefix: '*'
              destixxxPortRange: '65200-65535'
              protocol: 'Tcp'
              priority: 100
              direction: 'Inbound'
            }
          }
          {
            name: 'nsgsr-allow-azureloadbalancer-inbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: 'AzureLoadBalancer'
              sourcePortRange: '*'
              destixxxAddressPrefix: '*'
              destixxxPortRange: '65200-65535'
              protocol: 'Tcp'
              priority: 200
              direction: 'Inbound'
            }
          }
          {
            name: 'nsgsr-allow-internet-inbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: 'Internet'
              sourcePortRange: '*'
              destixxxAddressPrefix: '10.100.6.0/24'
              destixxxPortRanges: [
                80
                443
              ]
              protocol: 'Tcp'
              priority: 300
              direction: 'Inbound'
            }
          }
        ]
        defaultRules: 'Inbound'
      }
      {
        name: 'snet-apim'
        addressPrefix: '10.100.10.0/27'
        delegation: 'Microsoft.ApiManagement/service'
      }
      {
        name: 'snet-pep'
        addressPrefix: '10.100.10.32/27'
      }
      {
        name: 'snet-mgmt'
        addressPrefix: '10.100.10.64/27'
        rules: [
          {
            name: 'nsgsr-allow-bastion-inbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.9.64/26'
              sourcePortRange: '*'
              destixxxAddressPrefix: '10.100.10.64/27'
              destixxxPortRanges: [
                22
                3389
              ]
              protocol: 'Tcp'
              priority: 100
              direction: 'Inbound'
            }
          }
          {
            name: 'nsgsr-allow-all-spokes-outbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.10.64/27'
              sourcePortRange: '*'
              destixxxAddressPrefixes: [
                '10.100.0.0/16'
                '10.200.0.0/16'
              ]
              destixxxPortRange: '*'
              protocol: '*'
              priority: 100
              direction: 'Outbound'
            }
          }
          {
            name: 'nsgsr-allow-internet-outbound'
            properties: {
              access: 'Allow'
              sourceAddressPrefix: '10.100.10.64/27'
              sourcePortRange: '*'
              destixxxAddressPrefix: 'Internet'
              destixxxPortRange: '*'
              protocol: '*'
              priority: 200
              direction: 'Outbound'
            }
          }
        ]
      }
      {
        name: 'snet-inbound'
        addressPrefix: '10.100.10.96/27'
      }
      {
        name: 'snet-outbound'
        addressPrefix: '10.100.10.128/27'
        delegation: 'Microsoft.Web/serverFarms'
      }
    ]
  }
  kvPermissions: {
    appPermissions: {
      secrets: [
        'get'
      ]
    }
    userPermissions: {
      certificates: [
        'Get'
        'List'
        'Update'
        'Create'
        'Import'
        'Delete'
        'Recover'
        'Backup'
        'Restore'
        'ManageContacts'
        'ManageIssuers'
        'GetIssuers'
        'ListIssuers'
        'SetIssuers'
        'DeleteIssuers'
      ]
      keys: [
        'Get'
        'List'
        'Update'
        'Create'
        'Import'
        'Delete'
        'Recover'
        'Backup'
        'Restore'
        'GetRotationPolicy'
        'SetRotationPolicy'
        'Rotate'
        'Encrypt'
        'Decrypt'
        'UnwrapKey'
        'WrapKey'
        'Verify'
        'Sign'
        'Purge'
        'Release'
      ]
      secrets: [
        'Get'
        'List'
        'Set'
        'Delete'
        'Recover'
        'Backup'
        'Restore'
        'Purge'
      ]
    }
  }
}
