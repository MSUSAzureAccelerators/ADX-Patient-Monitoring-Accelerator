param deploymentLocation string = 'eastus'
param adxName string = 'adxclusterpatmon'
param adxSKU string = 'Standard_D11_v2'
param eventHubName string = 'eventhubpatmon'
param iotCentralName string = 'iotcentralpatmon'
param digitalTwinlName string = 'digitaltwinpatmon'

module iotCentralApp 'iotcentral.bicep' = {
  name: iotCentralName
  params: {
    iotCentralName: iotCentralName
    location: deploymentLocation
  }
}

module adxCluster './adx.bicep' = {
  name: adxName
  params: {
    adxName: adxName
    location: deploymentLocation
    adxSKU: adxSKU
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

module digitalTwin 'digitaltwin.bicep' = {
  name: digitalTwinlName
  params: {
    digitalTwinName: digitalTwinlName
    location: deploymentLocation
  }
}

resource adxNamePatientMonitoringiotdata 'Microsoft.Kusto/clusters/databases/dataConnections@2021-08-27' = {
  name: '${adxCluster.name}/PatientMonitoring/eventhubconnection'
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
    eventhub
  ]
}

output iotCentralName string = iotCentralName
