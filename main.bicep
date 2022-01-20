param adxName string
param location string = resourceGroup().location
param adxSKU string

resource adx 'Microsoft.Kusto/clusters@2021-08-27' = {
  name: adxName
  location: location
  sku: {
    name: adxSKU
    tier: 'Standard'
    capacity: 2
  }
  identity: {
    type: 'SystemAssigned'
  }

  resource adxDatabase 'databases@2021-08-27' = {
    kind: 'ReadWrite'
    name: 'PatientMonitoring'
   }
}

