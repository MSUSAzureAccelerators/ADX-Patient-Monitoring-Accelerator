
param iotCentralName string = 'iotcentralpatmon'

resource myIotCentralApp 'Microsoft.IoTCentral/iotApps@2021-06-01' = {
  name: iotCentralName
  location: resourceGroup().location
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
