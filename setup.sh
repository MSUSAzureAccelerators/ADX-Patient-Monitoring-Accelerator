#!/bin/bash

# Install/Update required eztensions
az extension add --name azure-iot --only-show-errors
az extension update --name azure-iot --only-show-errors

# Generate a unique suffix for the deployment and Resource Group
randomNum=$RANDOM

# Create parent resurce group
rgName=ADXConnectedDevices$randomNum
echo "1. Creating resource group: $rgName"
az group create --name $rgName --location "East US" --only-show-errors --output none

# Create all additional services using main Bicep template
deploymentName=ADXConnectedDevicesDeployment$randomNum
echo "2. Initiating Deployment: $deploymentName"
az deployment group create -n $deploymentName -g $rgName --template-file main.bicep --parameters deploymentSuffix=$randomNum @patientmonitoring.parameters.json --only-show-errors

# Sleep for 3 minutes to make sure subsequent calls return the correct data
sleep 3m

# Get IoT Central app ID:
iotCentralName=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.iotCentralName.value)
iotCentralAppID=$(az iot central app show -n $iotCentralName --query  applicationId)

# Get IoT Central Token 
az account get-access-token --resource https://apps.azureiotcentral.com --only-show-errors

# Deploy Smart Knee Brace imulated devices
smartKneeBraceDevices=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.smartKneeBraceDeviceNumber.value)
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

echo "4. Process completed"
