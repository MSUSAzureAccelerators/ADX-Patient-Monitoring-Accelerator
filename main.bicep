param deploymentLocation string = 'eastus'
param adxName string = 'adxclusterpatmon'
param eventHubName string = 'eventhubpatmon'

module adxCluster './adx.bicep' = {
  name: adxName
  params: {
    adxName: adxName
    location: deploymentLocation
    adxSKU: 'Standard_D11_v2'
  }
}

module eventhub 'eventhub.bicep' = {
  name: eventHubName
  params: {
    eventHubName: eventHubName
    location: deploymentLocation
    eventHubSKU: 'Standard'
  }
}

resource adxNamePatientMonitoringiotdata 'Microsoft.Kusto/clusters/databases/dataConnections@2021-08-27' = {
  name: '${adxCluster.name}/${eventhub.name}/dbconnect'
  kind: 'EventHub'
  location: deploymentLocation
  properties: {
    eventHubResourceId: '${eventhub.outputs.eventhubClusterId}/eventhubs/PatientMonitoring'
    consumerGroup: '$Default'
    tableName: 'TelemetryRaw'
    mappingRuleName: 'TelemetryRaw_mapping'
    dataFormat: 'JSON'
    compression: 'None'
    managedIdentityResourceId: adxCluster.outputs.adxClusterId
  }
  dependsOn: [
    adxCluster
  ]
}
