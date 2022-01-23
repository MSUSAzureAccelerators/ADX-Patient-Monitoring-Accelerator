param deploymentLocation string = 'eastus'
param adxName string = 'adxclusterpatmon'
param adxSKU string = 'Standard_D11_v2'
param eventHubName string = 'eventhubpatmon'
param iotCentralName string = 'iotcentralpatmon'
param digitalTwinlName string = 'digitaltwinpatmon'
param deploymentSuffix string
param smartKneeBraceDevices string
param vitalPatchDevices string

module iotCentralApp 'iotcentral.bicep' = {
  name: iotCentralName
  params: {
    iotCentralName: '${iotCentralName}${deploymentSuffix}'
    location: deploymentLocation
  }
}

module adxCluster './adx.bicep' = {
  name: adxName
  params: {
    adxName: '${adxName}${deploymentSuffix}'
    location: deploymentLocation
    adxSKU: adxSKU
  }
}

module eventhub 'eventhub.bicep' = {
  name: eventHubName
  params: {
    eventHubName: '${eventHubName}${deploymentSuffix}'
    location: deploymentLocation
    eventHubSKU: 'Standard'
  }
}

module digitalTwin 'digitaltwin.bicep' = {
  name: digitalTwinlName
  params: {
    digitalTwinName: '${digitalTwinlName}${deploymentSuffix}'
    location: deploymentLocation
  }
}

resource adxNamePatientMonitoringiotdata 'Microsoft.Kusto/clusters/databases/dataConnections@2021-08-27' = {
  name: '${adxName}${deploymentSuffix}/PatientMonitoring/eventhubconnection'
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

output iotCentralName string = '${iotCentralName}${deploymentSuffix}'
output smartKneeBraceDeviceNumber string = smartKneeBraceDevices
output vitalPatchDevicesNumber string = vitalPatchDevices
