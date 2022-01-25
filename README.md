# ADX Connected Devices - Patient Monitoring Demo

![alt tag](./assets/AutomationPresentation.gif)

This example shows how to use ADX to monitor a patient's vitals and knee brace readings


## Deployment instructions

From the Azure CLoud Shell :
1. Login to Azure Cloud Shell
```bash
az login
```
2. Optionally, if you have more than one subscription, select the appropriate one:
```bash
az account set --subscription "<your-subscription>"
```
3. Get the latest version of the repository
```bash
git clone -b refactor-to-modules https://github.com/bwatts64/PatientMonitoringDemo.git
```
4. Create all necessary resources
```bash
cd PatientMonitoringDemo
. ./setup.sh
```
5. Complete reosurce configuration
```bash
. ./configure.sh
```
# TODO:

Be aware of this error when running Configure.sh:
https://github.com/Azure/azure-cli/issues/11749#issuecomment-570975762
Just do az login and retry


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


# Add Digital Twin resources from IoT Central


## Clean up resources
az group delete --name ADXConnectedDevices


Todo from Brad:
- We need to automate the export job from IoT Central to the EventHub that was created
- We need to grant the 'Azure Digital Twins Data Owner' to the person running this. I had to add myself to login to ADT
- We need to automate the ADT environment