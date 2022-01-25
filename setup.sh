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
az deployment group create -n $deploymentName -g $rgName --template-file main.bicep --parameters deploymentSuffix=$randomNum @patientmonitoring.parameters.json --only-show-errors --output none

echo "3. Setup completed. Proceed to Configure"
export rgName
export deploymentName