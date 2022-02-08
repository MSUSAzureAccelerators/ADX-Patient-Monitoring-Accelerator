param eventHubName string
param location string = resourceGroup().location
param eventHubSKU string = 'Standard'
var eventHubAuthRuleName = 'ListenSend'

resource eventhubCluster 'Microsoft.EventHub/namespaces@2021-11-01' = {
  name: eventHubName
  location: location
  sku: {
    name: eventHubSKU
    tier: 'Standard'
    capacity: 1
  }
}

resource eventHubNamespaceName_eventHubName 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' = {
  parent: eventhubCluster
  name: 'PatientMonitoring'
  properties: {
    messageRetentionInDays: 7
    partitionCount: 1
  }
}

resource eventHubNamespaceName_kneebrace 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' = {
  parent: eventhubCluster
  name: 'kneebrace'
  properties: {
    messageRetentionInDays: 7
    partitionCount: 1
  }
}

resource eventHubNamespaceName_virtualpatch 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' = {
  parent: eventhubCluster
  name: 'virtualpatch'
  properties: {
    messageRetentionInDays: 7
    partitionCount: 1
  }
}

resource eventHubNamespaceName_virtualpatchfall 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' = {
  parent: eventhubCluster
  name: 'virtualpatchfall'
  properties: {
    messageRetentionInDays: 7
    partitionCount: 1
  }
}

// Grant Listen and Send on our event hub
resource eventHubNamespaceName_eventHubName_ListenSend 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2021-01-01-preview' = {
  parent: eventHubNamespaceName_eventHubName
  name: eventHubAuthRuleName
  properties: {
    rights: [
      'Listen'
      'Send'
    ]
  }
}

var eventHubConnectionString = listKeys(eventHubNamespaceName_eventHubName_ListenSend.id, eventHubNamespaceName_eventHubName_ListenSend.apiVersion).primaryConnectionString
output eventHubConnectionString string = eventHubConnectionString
output eventHubAuthRuleName string = eventHubAuthRuleName
output eventHubName string = eventHubName
output eventhubClusterId string = eventhubCluster.id 
output eventhubNamespace string = eventhubCluster.name
