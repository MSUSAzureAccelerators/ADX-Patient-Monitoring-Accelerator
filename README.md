# PatientMonitoringDemo


Deployment instructions

az group create --name ADXConnectedDevices --location "East US"

az deployment group create --name ADXConnectedDevicesDeployment --resource-group ADXConnectedDevices --template-file main.bicep --parameters @patientmonitoring.parameters.json
 
