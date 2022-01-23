#!/bin/bash

# Install/Update required eztensions
az extension add --name azure-iot
az extension update --name azure-iot

# Generate a unique suffix for the deployment and Resource Group
randomNum=$RANDOM

# Create parent resurce group
rgName=ADXConnectedDevices$randomNum
az group create --name $rgName --location "East US"

# Create all additional services using main Bicep template
deploymentName=ADXConnectedDevicesDeployment$randomNum
az deployment group create -n $deploymentName -g $rgName --template-file main.bicep --parameters deploymentSuffix=$randomNum @patientmonitoring.parameters.json

# Get IoT Central app ID:
iotCentralName=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.iotCentralName.value)
iotCentralAppID=$(az iot central app show -n $iotCentralName --query  applicationId)

# Deploy three simulated devices
for d in {1..3}
do
    deviceId=$(cat /proc/sys/kernel/random/uuid)
    az iot central device create --device-id $deviceId$d --app-id $iotCentralAppID --template dtmi:j71gm4wvkse:q2hnw2dwt --simulated
done
 
