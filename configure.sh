#!/bin/bash

# Get IoT Central app ID from previous deployment:
iotCentralName=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.iotCentralName.value --output tsv)
iotCentralAppID=$(az iot central app show -n $iotCentralName -g $rgName --query  applicationId --output tsv)

# Get IoT Central Token 
az account get-access-token --resource https://apps.azureiotcentral.com --only-show-errors

# Deploy Smart Knee Brace imulated devices
smartKneeBraceDevices=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.smartKneeBraceDeviceNumber.value --output tsv)
echo "3. Creating $smartKneeBraceDevices Smart Knee Brace devices on IoT Central: $iotCentralName ($iotCentralAppID)"
for (( c=1; c<=$smartKneeBraceDevices; c++ ))
do
    deviceId=$(cat /proc/sys/kernel/random/uuid)
    az iot central device create --device-id $deviceId$c --app-id $iotCentralAppID --template dtmi:j71gm4wvkse:q2hnw2dwt --simulated --only-show-errors
done
 
# DeployVitals Patch Simulated devices
vitalPatchDevices=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.vitalPatchDevicesNumber.value)
echo "4. Creating $vitalPatchDevices Vitals Patch devices on IoT Central: $iotCentralName ($iotCentralAppID)"
for (( c=1; c<=$vitalPatchDevices; c++ ))
do
    deviceId=$(cat /proc/sys/kernel/random/uuid)
    az iot central device create --device-id $deviceId$c --app-id $iotCentralAppID --template dtmi:hpzy1kfcbt2:umua7dplmbd --simulated --only-show-errors
done
