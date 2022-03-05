param location string = 'swedencentral'
param subnetid string 
param PublicIpAddressName string = 'GW01-PIP'

resource VNGW01 'Microsoft.Network/virtualNetworkGateways@2021-05-01' = {
  name: 'GW01'
  location: location
  
   properties: {
      gatewayType: 'Vpn'
      vpnType: 'RouteBased'
      sku: {
        name: 'Basic'
        tier: 'Basic'
      }
      vpnClientConfiguration: {
        vpnClientAddressPool: {
          addressPrefixes: [
            '10.5.0.0/16'
          ]
        }
        vpnClientRootCertificates: [
          
          {
            name: 'root3'
            properties: {
              publicCertData: 'MIIC5zCCAc+gAwIBAgIQf8NzHMbxKK9OZ6Kn6PdnSjANBgkqhkiG9w0BAQsFADAW MRQwEgYDVQQDDAtQMlNSb290Q2VydDAeFw0yMjAyMjYxMTA4MDBaFw0yMzAyMjYx MTI4MDBaMBYxFDASBgNVBAMMC1AyU1Jvb3RDZXJ0MIIBIjANBgkqhkiG9w0BAQEF AAOCAQ8AMIIBCgKCAQEAqNnGbpYWMs0vZYHbDgz3t236v2UGbi+OegJRjd+pl96n QrxiWXqgt4pnMWBAjbxQ5gX3mQzglMo31kR12Cbd/Kzv2Ag1wsj5UyvRQ2zu1KmT bL65Dw6ny7Tpf6oS9jIBgf24DVOvmhW8MnePGsGcwiRMXbsFzE2Lm09joYzDqHk4 sKQgzHmEPfLKyFGv1V5Ak4ItVq3ZwOOS2AryaYmcBe/BVk3HYpB4FDiLXGysGW66 7KiigR4Bm8WSF8fvQ8GdEior09dah8VcoK/bnikPnL6b+TnEnQM+2W+zUi565Gyj /6F5C/dZvdQ/v5vuBTkRmKyAqCT+TTHIjhOaCrfi3QIDAQABozEwLzAOBgNVHQ8B Af8EBAMCAgQwHQYDVR0OBBYEFEtD2uLjdVQYmOqCkpYNFfLPvvXGMA0GCSqGSIb3 DQEBCwUAA4IBAQCC1W760SrJbbXVS8vo1Osz8pK8ku+XFwneS9FW/UU+Rx3khmAN 0T/l6vmMfTzv16AMTewmBVvoXFv5AUZ33LPf75kUHwfKfUwN77jGkMURJXWiUBes S8jTPLjWhNNUymoWcAXzmcmGn0Z0DOYnssxKKyb3+EKYpHVt4L79B5Iwv1pYRdOA 6rv/q20po/Tf6mpVn3wh4l0Oy5PFHBDJQJrJWnLMiLn7hnWsVCoDUU5oK0pEMdB7 4B2UX+pVVOykvvE2cDktc4Lvsqk1TTVIaH3BzbTcxynW2Mr+OqJCELCAHkLgbc/P ev3PYsYN5LmGuIswnc6SJ3nhE+qdX7tsyMm/'
            }
          }
          
        ]
      }
      ipConfigurations: [
        {
          name: 'default'
          properties: {
            subnet: {
              id:  subnetid
            }
            publicIPAddress: {
              id: GW01PIP.id
            }
          }
        }
      ]

      
   }
  
}

resource GW01PIP 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: PublicIpAddressName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}
