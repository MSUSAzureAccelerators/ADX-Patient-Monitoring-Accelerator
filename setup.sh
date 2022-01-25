#!/bin/bash

# Install/Update required eztensions
az extension add --name azure-iot --only-show-errors
az extension update --name azure-iot --only-show-errors

# Generate a unique suffix for the deployment and Resource Group
randomNum=$RANDOM

# Create parent resurce group
echo "1. Creating resource group: $rgName"
rgName=ADXConnectedDevices$randomNum
az group create --name $rgName --location "East US" --only-show-errors --output none

# Create all additional services using main Bicep template
echo "2. Initiating Deployment: $deploymentName"
deploymentName=ADXConnectedDevicesDeployment$randomNum
principalId=$(az ad signed-in-user show --query objectId -o tsv)
az deployment group create -n $deploymentName -g $rgName --template-file main.bicep --parameters deploymentSuffix=$randomNum principalId=$principalId @patientmonitoring.parameters.json --only-show-errors --output none

echo "3. Setup completed. Proceed to Configure"
export rgName
export deploymentName