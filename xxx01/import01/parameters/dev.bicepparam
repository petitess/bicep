using '../main.bicep'
import * as newObject from '../import.bicep'

param environment = 'dev'
param config = {
  product: 'abc'
  location: 'we'
  tags: {
    Product: 'Common Infrastructure'
    Environment: 'Development'
    CostCenter: '0000'
  }
}

param objectX = newObject.my_object
