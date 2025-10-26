using '../main.bicep'

param env = 'dev'
param config = {
  product: 'abc'
  location: 'sc'
  tags: {
    Product: 'Common Infrastructure'
    Environment: 'Development'
    CostCenter: '0000'
  }
}
