param eventHubName string
param location string = resourceGroup().location
param eventHubSKU string = 'Standard'

resource eventhubCluster 'Microsoft.EventHub/namespaces@2021-11-01' = {
  name: eventHubName
  location: location
  sku: {
    name: eventHubSKU
    tier: 'Standard'
    capacity: 1
  }

  resource eventhubs 'eventhubs@2021-11-01' = {
    name: 'PatientMonitoring'
  }
}

output eventhubClusterId string = eventhubCluster.id 
output eventhubNamespace string = eventhubCluster.name
