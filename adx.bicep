param adxName string
param location string = resourceGroup().location
param adxSKU string

resource adxCluster 'Microsoft.Kusto/clusters@2021-08-27' = {
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
    
    resource adxName_PatientMonitoring_ConfigDB 'scripts@2021-08-27' = {
      name: 'ConfigDB'
      properties: {
        forceUpdateTag: 'Test2'
        scriptUrl: 'https://patientmonitoringsa.blob.core.windows.net/script/configDB.kql'
        scriptUrlSasToken: 'sp=r&st=2022-01-19T19:44:47Z&se=2025-01-20T03:44:47Z&spr=https&sv=2020-08-04&sr=b&sig=kFSN5jRC9r3GNe9WHclIDMbXP%2Bcx3pvJyhGaLUyFJXk%3D'
      }
    }
   }
}

output adxClusterId string = adxCluster.id

