using './main.bicep'

param environment = 'prod'

param config = {
  product: 'infra'
  location: 'sc'
  tags: {
    Product: 'Common Infrastructure'
    Environment: 'Production'
    CostCenter: '0000'
  }
}
