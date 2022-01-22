# PatientMonitoringDemo

Login to Azure Cloud Shell

# Get the latest version of the repository

git clone -b refactor-to-modules https://github.com/bwatts64/PatientMonitoringDemo.git

## Deployment instructions

az group create --name ADXConnectedDevices2 --location "East US"

az deployment group create --name ADXConnectedDevicesDeployment --resource-group ADXConnectedDevices2 --template-file main.bicep --parameters @patientmonitoring.parameters.json

# Get IoT Central app ID:
az deployment group show -g ADXConnectedDevices2 -n ADXConnectedDevicesDeployment --query properties.outputs.iotCentralAppID.value

## Deploying devices
az iot central device create --device-id abc1234 --app-id 1ca22cf5-838f-4134-ba74-4c2fa6e76d20 --template dtmi:j71gm4wvkse:q2hnw2dwt --simulated


# Create IoT Central Export destination:
# https://docs.microsoft.com/en-us/cli/azure/iot/central/export/destination?view=azure-cli-latest#az-iot-central-export-destination-create
az iot central export destination create --app-id
                                         --dest-id
                                         --display-name
                                         --type {blobstorage@v1, dataexplorer@v1, eventhubs@v1, servicebusqueue@v1, servicebustopic@v1, webhook@v1}
                                         [--api-version {1.1-preview}]
                                         [--au]
                                         [--central-api-uri]
                                         [--cluster-url]
                                         [--database]
                                         [--header]
                                         [--table]
                                         [--token]
                                         [--url]

# Event Hub example:
az iot central export destination create --app-id {appid} --dest-id {destintionid} --type eventhubs@v1 --name {displayname} --authorization '{
  "type": "connectionString",
  "connectionString": "Endpoint=sb://[hubName].servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=*****;EntityPath=entityPath1"
}'

# Create IoT Central App export:
# https://docs.microsoft.com/en-us/cli/azure/iot/central/export?view=azure-cli-latest#az-iot-central-export-create
az iot central export create --app-id
                             --destinations
                             --display-name
                             --export-id
                             --source {deviceConnectivity, deviceLifecycle, deviceTemplateLifecycle, properties, telemetry}
                             [--api-version {1.1-preview}]
                             [--central-api-uri]
                             [--en]
                             [--enabled {false, true}]
                             [--filter]
                             [--token]
# Example:
az iot central export create --app-id {appid} --export-id {exportid} --enabled {enabled} --display-name {displayname} --source {source} --filter "SELECT * FROM devices WHERE $displayName != "abc" AND $id = "a"" --enrichments '{
  "simulated": {
    "path": "$simulated"
  }
}' --destinations '[
  {
    "id": "{destinationid}",
    "transform": "{ ApplicationId: .applicationId, Component: .component, DeviceName: .device.name }"
  }
]'


## Clean up resources
az group delete --name ADXConnectedDevices
