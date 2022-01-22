param digitalTwinName string
param location string = resourceGroup().location

resource digitaltwin 'Microsoft.DigitalTwins/digitalTwinsInstances@2020-12-01' = {
  name: digitalTwinName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
  }
}
