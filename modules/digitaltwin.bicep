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

output digitalTwinName string = digitaltwin.name
output digitalTwinHostName string = digitaltwin.properties.hostName
output digitalTwinId string = digitaltwin.id
