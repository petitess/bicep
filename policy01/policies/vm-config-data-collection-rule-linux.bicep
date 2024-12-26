targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'VM1'
  properties: {
    displayName: 'VM1: Configure Linux Machines to be associated with a Data Collection Rule or a Data Collection Endpoint'
    description: 'Configure Linux Machines to be associated with a Data Collection Rule or a Data Collection Endpoint'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'VirtualMAchine'
    }
    parameters: {
      dcrResourceId: {
        defaultValue: '/subscriptions/ab883f14-0eb6-480b-995f-4b6340159245/resourceGroups/rg-security-governance-prd-XXXX/providers/Microsoft.Insights/dataCollectionRules/dcr-security-governance-prd-XXXX'
        metadata: {
          description: 'Resource Id of the Data Collection Rule or the Data Collection Endpoint to be applied on the Linux machines in scope.'
          displayName: 'Data Collection Rule Resource Id or Data Collection Endpoint Resource Id'
          portalReview: 'true'
        }
        type: 'String'
      }
      effect: {
        allowedValues: [
          'DeployIfNotExists'
          'Disabled'
        ]
        defaultValue: 'DeployIfNotExists'
        metadata: {
          description: 'Enable or disable the execution of the policy.'
          displayName: 'Effect'
        }
        type: 'String'
      }
      listOfLinuxImageIdToInclude: {
        defaultValue: []
        metadata: {
          description: 'List of machine images that have supported Linux OS to add to scope. Example values: \'/subscriptions/<subscriptionId>/resourceGroups/YourResourceGroup/providers/Microsoft.Compute/images/ContosoStdImage\''
          displayName: 'Additional Linux Machine Images'
        }
        type: 'Array'
      }
      resourceType: {
        allowedValues: [
          'Microsoft.Insights/dataCollectionRules'
          'Microsoft.Insights/dataCollectionEndpoints'
        ]
        defaultValue: 'Microsoft.Insights/dataCollectionRules'
        metadata: {
          description: 'Either a Data Collection Rule (DCR) or a Data Collection Endpoint (DCE)'
          displayName: 'Resource Type'
          portalReview: 'true'
        }
        type: 'String'
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'location'
            in: [
              'australiacentral'
              'australiacentral2'
              'australiaeast'
              'australiasoutheast'
              'brazilsouth'
              'brazilsoutheast'
              'canadacentral'
              'canadaeast'
              'centralindia'
              'centralus'
              'eastasia'
              'eastus'
              'eastus2'
              'eastus2euap'
              'francecentral'
              'francesouth'
              'germanywestcentral'
              'japaneast'
              'japanwest'
              'jioindiawest'
              'koreacentral'
              'koreasouth'
              'northcentralus'
              'northeurope'
              'norwayeast'
              'norwaywest'
              'southafricanorth'
              'southcentralus'
              'southeastasia'
              'southindia'
              'swedencentral'
              'switzerlandnorth'
              'switzerlandwest'
              'uaenorth'
              'uksouth'
              'ukwest'
              'westcentralus'
              'westeurope'
              'westindia'
              'westus'
              'westus2'
              'westus3'
            ]
          }
          {
            anyOf: [
              {
                allOf: [
                  {
                    equals: 'Microsoft.HybridCompute/machines'
                    field: 'type'
                  }
                  {
                    equals: 'linux'
                    field: 'Microsoft.HybridCompute/machines/osName'
                  }
                ]
              }
              {
                allOf: [
                  {
                    anyOf: [
                      {
                        equals: 'Microsoft.Compute/virtualMachines'
                        field: 'type'
                      }
                      {
                        equals: 'Microsoft.Compute/virtualMachineScaleSets'
                        field: 'type'
                      }
                    ]
                  }
                  {
                    anyOf: [
                      {
                        field: 'Microsoft.Compute/imageId'
                        in: '''[parameters('listOfLinuxImageIdToInclude')]'''
                      }
                      {
                        allOf: [
                          {
                            equals: 'RedHat'
                            field: 'Microsoft.Compute/imagePublisher'
                          }
                          {
                            field: 'Microsoft.Compute/imageOffer'
                            in: [
                              'RHEL'
                              'RHEL-ARM64'
                              'RHEL-BYOS'
                              'RHEL-HA'
                              'RHEL-SAP'
                              'RHEL-SAP-APPS'
                              'RHEL-SAP-HA'
                            ]
                          }
                          {
                            anyOf: [
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: '7*'
                              }
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: '8*'
                              }
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: 'rhel-lvm7*'
                              }
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: 'rhel-lvm8*'
                              }
                            ]
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            equals: 'SUSE'
                            field: 'Microsoft.Compute/imagePublisher'
                          }
                          {
                            anyOf: [
                              {
                                allOf: [
                                  {
                                    field: 'Microsoft.Compute/imageOffer'
                                    in: [
                                      'SLES'
                                      'SLES-HPC'
                                      'SLES-HPC-Priority'
                                      'SLES-SAP'
                                      'SLES-SAP-BYOS'
                                      'SLES-Priority'
                                      'SLES-BYOS'
                                      'SLES-SAPCAL'
                                      'SLES-Standard'
                                    ]
                                  }
                                  {
                                    anyOf: [
                                      {
                                        field: 'Microsoft.Compute/imageSku'
                                        like: '12*'
                                      }
                                      {
                                        field: 'Microsoft.Compute/imageSku'
                                        like: '15*'
                                      }
                                    ]
                                  }
                                ]
                              }
                              {
                                allOf: [
                                  {
                                    anyOf: [
                                      {
                                        field: 'Microsoft.Compute/imageOffer'
                                        like: 'sles-12*'
                                      }
                                      {
                                        field: 'Microsoft.Compute/imageOffer'
                                        like: 'sles-15*'
                                      }
                                    ]
                                  }
                                  {
                                    field: 'Microsoft.Compute/imageSku'
                                    in: [
                                      'gen1'
                                      'gen2'
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            equals: 'Canonical'
                            field: 'Microsoft.Compute/imagePublisher'
                          }
                          {
                            anyOf: [
                              {
                                equals: 'UbuntuServer'
                                field: 'Microsoft.Compute/imageOffer'
                              }
                              {
                                field: 'Microsoft.Compute/imageOffer'
                                like: '0001-com-ubuntu-server-*'
                              }
                              {
                                field: 'Microsoft.Compute/imageOffer'
                                like: '0001-com-ubuntu-pro-*'
                              }
                            ]
                          }
                          {
                            field: 'Microsoft.Compute/imageSku'
                            in: [
                              '14.04.0-lts'
                              '14.04.1-lts'
                              '14.04.2-lts'
                              '14.04.3-lts'
                              '14.04.4-lts'
                              '14.04.5-lts'
                              '16_04_0-lts-gen2'
                              '16_04-lts-gen2'
                              '16.04-lts'
                              '16.04.0-lts'
                              '18_04-lts-arm64'
                              '18_04-lts-gen2'
                              '18.04-lts'
                              '20_04-lts-arm64'
                              '20_04-lts-gen2'
                              '20_04-lts'
                              '22_04-lts-gen2'
                              '22_04-lts'
                              'pro-16_04-lts-gen2'
                              'pro-16_04-lts'
                              'pro-18_04-lts-gen2'
                              'pro-18_04-lts'
                              'pro-20_04-lts-gen2'
                              'pro-20_04-lts'
                              'pro-22_04-lts-gen2'
                              'pro-22_04-lts'
                            ]
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            equals: 'Oracle'
                            field: 'Microsoft.Compute/imagePublisher'
                          }
                          {
                            equals: 'Oracle-Linux'
                            field: 'Microsoft.Compute/imageOffer'
                          }
                          {
                            anyOf: [
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: '7*'
                              }
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: '8*'
                              }
                            ]
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            equals: 'OpenLogic'
                            field: 'Microsoft.Compute/imagePublisher'
                          }
                          {
                            field: 'Microsoft.Compute/imageOffer'
                            in: [
                              'CentOS'
                              'Centos-LVM'
                              'CentOS-SRIOV'
                            ]
                          }
                          {
                            anyOf: [
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: '6*'
                              }
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: '7*'
                              }
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: '8*'
                              }
                            ]
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            equals: 'cloudera'
                            field: 'Microsoft.Compute/imagePublisher'
                          }
                          {
                            equals: 'cloudera-centos-os'
                            field: 'Microsoft.Compute/imageOffer'
                          }
                          {
                            field: 'Microsoft.Compute/imageSku'
                            like: '7*'
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            equals: 'almalinux'
                            field: 'Microsoft.Compute/imagePublisher'
                          }
                          {
                            equals: 'almalinux'
                            field: 'Microsoft.Compute/imageOffer'
                          }
                          {
                            field: 'Microsoft.Compute/imageSku'
                            like: '8*'
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            equals: 'ctrliqinc1648673227698'
                            field: 'Microsoft.Compute/imagePublisher'
                          }
                          {
                            field: 'Microsoft.Compute/imageOffer'
                            like: 'rocky-8*'
                          }
                          {
                            field: 'Microsoft.Compute/imageSku'
                            like: 'rocky-8*'
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            equals: 'credativ'
                            field: 'Microsoft.Compute/imagePublisher'
                          }
                          {
                            field: 'Microsoft.Compute/imageOffer'
                            in: [
                              'Debian'
                            ]
                          }
                          {
                            equals: '9'
                            field: 'Microsoft.Compute/imageSku'
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            equals: 'Debian'
                            field: 'Microsoft.Compute/imagePublisher'
                          }
                          {
                            field: 'Microsoft.Compute/imageOffer'
                            in: [
                              'debian-10'
                              'debian-11'
                            ]
                          }
                          {
                            field: 'Microsoft.Compute/imageSku'
                            in: [
                              '10'
                              '10-gen2'
                              '11'
                              '11-gen2'
                            ]
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            equals: 'microsoftcblmariner'
                            field: 'Microsoft.Compute/imagePublisher'
                          }
                          {
                            equals: 'cbl-mariner'
                            field: 'Microsoft.Compute/imageOffer'
                          }
                          {
                            field: 'Microsoft.Compute/imageSku'
                            in: [
                              '1-gen2'
                              'cbl-mariner-1'
                              'cbl-mariner-2'
                              'cbl-mariner-2-arm64'
                              'cbl-mariner-2-gen2'
                            ]
                          }
                        ]
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }
      then: {
        details: {
          deployment: {
            properties: {
              mode: 'incremental'
              parameters: {
                dcrResourceId: {
                  value: '''[parameters('dcrResourceId')]'''
                }
                location: {
                  value: '''[field('location')]'''
                }
                resourceName: {
                  value: '''[field('name')]'''
                }
                resourceType: {
                  value: '''[parameters('resourceType')]'''
                }
                type: {
                  value: '''[field('type')]'''
                }
              }
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  dcrResourceId: {
                    type: 'string'
                  }
                  location: {
                    type: 'string'
                  }
                  resourceName: {
                    type: 'string'
                  }
                  resourceType: {
                    type: 'string'
                  }
                  type: {
                    type: 'string'
                  }
                }
                resources: [
                  {
                    apiVersion: '2021-04-01'
                    condition: '''[and(equals(toLower(parameters('type')), 'microsoft.compute/virtualmachines'), equals(parameters('resourceType'), variables('dcrResourceType')))]'''
                    name: '''[variables('dcrAssociationName')]'''
                    properties: {
                      dataCollectionRuleId: '''[replace(parameters('dcrResourceId'), 'XXXX', parameters('location'))]'''
                    }
                    scope: '''[concat('Microsoft.Compute/virtualMachines/', parameters('resourceName'))]'''
                    type: 'Microsoft.Insights/dataCollectionRuleAssociations'
                  }
                  {
                    apiVersion: '2021-04-01'
                    condition: '''[and(equals(toLower(parameters('type')), 'microsoft.compute/virtualmachines'), equals(parameters('resourceType'), variables('dceResourceType')))]'''
                    name: '''[variables('dceAssociationName')]'''
                    properties: {
                      dataCollectionEndpointId: '''[replace(parameters('dcrResourceId'), 'XXXX', parameters('location'))]'''
                    }
                    scope: '''[concat('Microsoft.Compute/virtualMachines/', parameters('resourceName'))]'''
                    type: 'Microsoft.Insights/dataCollectionRuleAssociations'
                  }
                  {
                    apiVersion: '2021-04-01'
                    condition: '''[and(equals(toLower(parameters('type')), 'microsoft.compute/virtualmachinescalesets'), equals(parameters('resourceType'), variables('dcrResourceType')))]'''
                    name: '''[variables('dcrAssociationName')]'''
                    properties: {
                      dataCollectionRuleId: '''[replace(parameters('dcrResourceId'), 'XXXX', parameters('location'))]'''
                    }
                    scope: '''[concat('Microsoft.Compute/virtualMachineScaleSets/', parameters('resourceName'))]'''
                    type: 'Microsoft.Insights/dataCollectionRuleAssociations'
                  }
                  {
                    apiVersion: '2021-04-01'
                    condition: '''[and(equals(toLower(parameters('type')), 'microsoft.compute/virtualmachinescalesets'), equals(parameters('resourceType'), variables('dceResourceType')))]'''
                    name: '''[variables('dceAssociationName')]'''
                    properties: {
                      dataCollectionEndpointId: '''[replace(parameters('dcrResourceId'), 'XXXX', parameters('location'))]'''
                    }
                    scope: '''[concat('Microsoft.Compute/virtualMachineScaleSets/', parameters('resourceName'))]'''
                    type: 'Microsoft.Insights/dataCollectionRuleAssociations'
                  }
                  {
                    apiVersion: '2021-04-01'
                    condition: '''[and(equals(toLower(parameters('type')), 'microsoft.hybridcompute/machines'), equals(parameters('resourceType'), variables('dcrResourceType')))]'''
                    name: '''[variables('dcrAssociationName')]'''
                    properties: {
                      dataCollectionRuleId: '''[replace(parameters('dcrResourceId'), 'XXXX', parameters('location'))]'''
                    }
                    scope: '''[concat('Microsoft.HybridCompute/machines/', parameters('resourceName'))]'''
                    type: 'Microsoft.Insights/dataCollectionRuleAssociations'
                  }
                  {
                    apiVersion: '2021-04-01'
                    condition: '''[and(equals(toLower(parameters('type')), 'microsoft.hybridcompute/machines'), equals(parameters('resourceType'), variables('dceResourceType')))]'''
                    name: '''[variables('dceAssociationName')]'''
                    properties: {
                      dataCollectionEndpointId: '''[replace(parameters('dcrResourceId'), 'XXXX', parameters('location'))]'''
                    }
                    scope: '''[concat('Microsoft.HybridCompute/machines/', parameters('resourceName'))]'''
                    type: 'Microsoft.Insights/dataCollectionRuleAssociations'
                  }
                ]
                variables: {
                  dceAssociationName: 'configurationAccessEndpoint'
                  dceResourceType: 'Microsoft.Insights/dataCollectionEndpoints'
                  dcrAssociationName: '''[concat('assoc-', uniqueString(concat(parameters('resourceName'), replace(parameters('dcrResourceId'), 'XXXX', parameters('location')))))]'''
                  dcrResourceType: 'Microsoft.Insights/dataCollectionRules'
                }
              }
            }
          }
          evaluationDelay: 'AfterProvisioning'
          existenceCondition: {
            anyOf: [
              {
                contains: '''[substring(parameters('dcrResourceId'),0,93)]'''
                field: 'Microsoft.Insights/dataCollectionRuleAssociations/dataCollectionRuleId'
              }
              {
                contains: '''[substring(parameters('dcrResourceId'),0,93)]'''
                field: 'Microsoft.Insights/dataCollectionRuleAssociations/dataCollectionEndpointId'
              }
            ]
          }
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa'
            '/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
          ]
          type: 'Microsoft.Insights/dataCollectionRuleAssociations'
        }
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
