param deploymentLocation string = 'eastus'
param adxName string = 'adxclusterpatmon'
param adxSKU string = 'Standard_D11_v2'
param eventHubName string = 'eventhubpatmon'
param iotCentralName string = 'iotcentralpatmon'
param digitalTwinlName string = 'digitaltwinpatmon'
param saName string = 'patientmonitoringsa'
param deploymentSuffix string
param smartKneeBraceDevices int
param vitalPatchDevices int
param principalId string

module iotCentralApp './modules/iotcentral.bicep' = {
  name: iotCentralName
  params: {
    iotCentralName: '${iotCentralName}${deploymentSuffix}'
    location: deploymentLocation
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

module storageAccount './modules/storage.bicep' = {
  name: '${saName}${deploymentSuffix}'
  params: {
   saname: '${saName}${deploymentSuffix}'
   location: deploymentLocation
   eventHubId: '${eventhub.outputs.eventhubClusterId}'
  }
}

module digitalTwin './modules/digitaltwin.bicep' = {
  name: digitalTwinlName
  params: {
    digitalTwinName: '${digitalTwinlName}${deploymentSuffix}'
    location: deploymentLocation
  }
}

// Get Azure Event Hubs Data receiver role definition
@description('This is the built-in Azure Event Hubs Data receiver role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
resource eventHubsDataReceiverRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: 'a638d3c7-ab3a-418d-83e6-5f17a39d4fde'
}

// Get Event Hub Reference (deployed in Module)
resource eventHubReference 'Microsoft.EventHub/namespaces@2021-11-01'  existing = {
  name: '${eventHubName}${deploymentSuffix}'
}

// Grant Azure Event Hubs Data receiver role to ADX
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, principalId, eventHubsDataReceiverRoleDefinition.id)
  scope: eventHubReference
  properties: {
    roleDefinitionId: eventHubsDataReceiverRoleDefinition.id
    principalId: adxCluster.outputs.adxClusterIdentity
  }
}


output iotCentralName string = '${iotCentralName}${deploymentSuffix}'
output smartKneeBraceDeviceNumber int = smartKneeBraceDevices
output vitalPatchDevicesNumber int = vitalPatchDevices
output eventHubConnectionString string = eventhub.outputs.eventHubConnectionString
output eventHubAuthRuleName string = eventhub.outputs.eventHubAuthRuleName
output eventHubName string = eventhub.outputs.eventHubName
output eventhubClusterId string = eventhub.outputs.eventhubClusterId
output eventhubNamespace string = eventhub.outputs.eventhubNamespace
output digitalTwinName string = digitalTwin.outputs.digitalTwinName
output digitalTwinHostName string = digitalTwin.outputs.digitalTwinHostName
output digitalTwinId string = digitalTwin.outputs.digitalTwinId
output saName string = storageAccount.outputs.saName
output saId string = storageAccount.outputs.saId
output adxName string = adxCluster.outputs.adxName
output adxClusterId string = adxCluster.outputs.adxClusterId
output location string = deploymentLocation

