param deploymentLocation string = 'eastus'
param adxName string = 'adxclusterpatmon'
param adxSKU string = 'Standard_D11_v2'
param eventHubName string = 'eventhubpatmon'
param iotCentralName string = 'iotcentralpatmon'
param digitalTwinlName string = 'digitaltwinpatmon'
param deploymentSuffix string
param smartKneeBraceDevices int
param vitalPatchDevices int
param principalId string

module iotCentralApp './modules/iotcentral.bicep' = {
  name: iotCentralName
  params: {
    iotCentralName: '${iotCentralName}${deploymentSuffix}'
    location: deploymentLocation
    principalId: principalId
  }
}

module adxCluster './modules/adx.bicep' = {
  name: adxName
  params: {
    adxName: '${adxName}${deploymentSuffix}'
    location: deploymentLocation
    adxSKU: adxSKU
  }
}

module eventhub './modules/eventhub.bicep' = {
  name: eventHubName
  params: {
    eventHubName: '${eventHubName}${deploymentSuffix}'
    location: deploymentLocation
    eventHubSKU: 'Standard'
  }
}

module digitalTwin './modules/digitaltwin.bicep' = {
  name: digitalTwinlName
  params: {
    digitalTwinName: '${digitalTwinlName}${deploymentSuffix}'
    location: deploymentLocation
  }
}

@description('This is the built-in Azure Event Hubs Data receiver role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
resource eventHubsDataReceiverRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: 'a638d3c7-ab3a-418d-83e6-5f17a39d4fde'
}

// Grant Azure Event Hubs Data receiver role to ADX
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, principalId, eventHubsDataReceiverRoleDefinition.id)
  properties: {
    roleDefinitionId: eventHubsDataReceiverRoleDefinition.id
    principalId: adxCluster.outputs.adxClusterId
  }
}

// Add Azure Event Hubs data connection to ADX database
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
output smartKneeBraceDeviceNumber int = smartKneeBraceDevices
output vitalPatchDevicesNumber int = vitalPatchDevices
output eventHubConnectionString string = eventhub.outputs.eventHubConnectionString
output eventHubAuthRuleName string = eventhub.outputs.eventHubAuthRuleName
output eventHubName string = eventhub.outputs.eventHubName
output eventhubClusterId string = eventhub.outputs.eventhubClusterId
output eventhubNamespace string = eventhub.outputs.eventhubNamespace

