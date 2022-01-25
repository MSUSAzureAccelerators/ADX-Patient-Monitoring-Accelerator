#!/bin/bash

# Get IoT Central app ID from previous deployment:
iotCentralName=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.iotCentralName.value --output tsv)
iotCentralAppID=$(az iot central app show -n $iotCentralName -g $rgName --query  applicationId --output tsv)

# Get IoT Central Token 
az account get-access-token --resource https://apps.azureiotcentral.com --only-show-errors --output none

# Deploy Smart Knee Brace imulated devices
smartKneeBraceDevices=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.smartKneeBraceDeviceNumber.value --output tsv)
echo "3. Creating $smartKneeBraceDevices Smart Knee Brace devices on IoT Central: $iotCentralName ($iotCentralAppID)"
for (( c=1; c<=$smartKneeBraceDevices; c++ ))
do
    deviceId=$(cat /proc/sys/kernel/random/uuid)
    az iot central device create --device-id $deviceId$c --app-id $iotCentralAppID --template dtmi:j71gm4wvkse:q2hnw2dwt --simulated --only-show-errors --output none
done
 
# DeployVitals Patch Simulated devices
vitalPatchDevices=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.vitalPatchDevicesNumber.value)
echo "4. Creating $vitalPatchDevices Vitals Patch devices on IoT Central: $iotCentralName ($iotCentralAppID)"
for (( c=1; c<=$vitalPatchDevices; c++ ))
do
    deviceId=$(cat /proc/sys/kernel/random/uuid)
    az iot central device create --device-id $deviceId$c --app-id $iotCentralAppID --template dtmi:hpzy1kfcbt2:umua7dplmbd --simulated --only-show-errors --output none
done

# On IoT Central, create an Event Hub export destination with json payload
echo "5. Creating Event Hub export destination on IoT Central: $iotCentralName ($iotCentralAppID)"
eventHubConnectionString=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.eventHubConnectionString.value --output tsv)
az iot central export destination create --app-id $iotCentralAppID --dest-id 'eventHubExport' --type eventhubs@v1 --name 'eventHubExport' --authorization '{"type": "connectionString", "connectionString": "'$eventHubConnectionString'" }' --output none

# Create IoT Central App Export using previoulsy created destination
echo "6. Creating IoT Central App Export on IoT Central: $iotCentralName ($iotCentralAppID)"
az iot central export create --app-id $iotCentralAppID --export-id 'iotEventHubExport' --display-name 'iotEventHubExport' --source 'telemetry' --destinations '[{"id": "eventHubExport"}]' --output none

# Complete Azure Digital Twins Envirtonment setup