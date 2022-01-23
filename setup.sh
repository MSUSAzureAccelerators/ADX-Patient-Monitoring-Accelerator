#!/bin/bash

# Install/Update required eztensions
az extension add --name azure-iot --only-show-errors
az extension update --name azure-iot --only-show-errors

# Generate a unique suffix for the deployment and Resource Group
randomNum=$RANDOM

# Create parent resurce group
rgName=ADXConnectedDevices$randomNum
echo "1. Creating resource group: $rgName"
az group create --name $rgName --location "East US" --only-show-errors

# Create all additional services using main Bicep template
deploymentName=ADXConnectedDevicesDeployment$randomNum
echo "2. Initiating Deployment: $deploymentName"
az deployment group create -n $deploymentName -g $rgName --template-file main.bicep --parameters deploymentSuffix=$randomNum @patientmonitoring.parameters.json --only-show-errors

# Get IoT Central app ID:
iotCentralName=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.iotCentralName.value)
iotCentralAppID=$(az iot central app show -n $iotCentralName --query  applicationId)

# Deploy three simulated devices -- Complete this section
# numDevType1=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.iotCentralName.value)
numDevType1='5'
echo "3. Creating $numDevType1 devices on IoT Central: $iotCentralName ($iotCentralAppID)"
for (( c=1; c<=$numDevType1; c++ ))
do
    deviceId=$(cat /proc/sys/kernel/random/uuid)
    az iot central device create --device-id $deviceId$c --app-id $iotCentralAppID --template dtmi:j71gm4wvkse:q2hnw2dwt --simulated --only-show-errors
done
 
echo "4. Process completed"