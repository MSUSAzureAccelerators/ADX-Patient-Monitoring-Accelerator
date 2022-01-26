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


## Clean up resources
az group delete --name ADXConnectedDevices