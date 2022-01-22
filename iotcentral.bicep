
param iotCentralName string = 'iotcentralpatmon'
param location string = resourceGroup().location

resource myIotCentralApp 'Microsoft.IoTCentral/iotApps@2021-06-01' = {
  name: iotCentralName
  location: location
  sku: {
    name: 'ST1'
   }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: 'Continuous Patient Monitoring'
    subdomain: '${iotCentralName}domain'
    template: 'iotc-patient'
  }
}
