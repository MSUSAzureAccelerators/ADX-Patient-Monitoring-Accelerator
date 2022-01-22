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




## Clean up resources
az group delete --name ADXConnectedDevices
