# ADX Connected Devices - Patient Monitoring Demo

![alt tag](./assets/AutomationPresentation.gif)

This example shows how to use ADX to monitor a patient's vitals and knee brace readings. It leverages (Azure Bicep)[https://docs.microsoft.com/EN-US/azure/azure-resource-manager/bicep/] and the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/) to automate the entire deployment.

The solution uses [Azure IoT Central](https://azure.microsoft.com/en-us/services/iot-central/) Continuous Patient Monitoring [application](https://docs.microsoft.com/en-us/azure/iot-central/core/concepts-app-templates#continuous-patient-monitoring) to generate telemetry readings for two IoT Consumer devices: automated knee brace and a vitals monitor patch. The generated data is automatically send to an [Azure Event Hub](https://azure.microsoft.com/en-us/services/event-hubs/) and then send to an [Azure Data Explorer](https://azure.microsoft.com/en-us/services/data-explorer/) for analysis.

An [Azure Digital Twins](https://azure.microsoft.com/en-us/services/digital-twins/) service is used to store additional simulated devices metadata.

The Azure Data Explorer cluster is configured with a database, a set of tables to store telemetry data from both devices, and a set of functions to parse incoming data and to query data directly from the Azure Digital Twins service.

The solution includes a [Power BI](https://powerbi.microsoft.com/en-us/) report to visualize the data. Just download the [file](/assets/Connected_Devices.pbix) and open it in Power BI.  


## Deployment instructions

On the [Azure Cloud Shell](https://shell.azure.com/) run the following commands to deploy the solution:
1. Login to Azure
    ```bash
    az login
    ```

2. If you have more than one subscription, select the appropriate one:
    ```bash
    az account set --subscription "<your-subscription>"
    ```

3. Get the latest version of the repository
    ```bash
    git clone -b refactor-to-modules https://github.com/<<<FINALREPO>>>/PatientMonitoringDemo.git
    ```
    Optionally, You can update the patientmonitoring.parameters.json file to personalize your deployment.

4. Deploy solution
    ```bash
    cd PatientMonitoringDemo
    . ./deploy.sh
    ```

5. Finally, download the [Power BI report](/assets/Connected_Devices.pbix), update the data source to point to yoir newly deployed Azure Data Explorer database, and refresh the data in the report.

## Files used in the solution

- **asssets folder**: contains the following files:
  - AutomationPresentation.gif: quick explanation of the solution
  - Connected_Devices.pbix : sample report to visualize the data

- **config folder**: contains the configDB.kql that includes the code required to create the Azure Data Explorer tables and functions

- **dtconfig folder**: contains the files necessary to configure the Azure Digital Twins service:
  - Departments.json
  - Facility.json
  - KneeBrace.json
  - VirtualPatch.json

- **modules folder**: contains the [Azure Bicep](https://docs.microsoft.com/EN-US/azure/azure-resource-manager/bicep/) necessary to deploy and configure the resource resources used in the solution:
  - adx.bicep: ADX Bicep deployment file
  - digitaltwin.bicep: Digital Twin Bicep deployment file
  - eventhub.bicep: Event Hub Bicep deployment file
  - iotcentral.bicep: IoT Central Bicep deployment file
  - storage.bicep: Storage Bicep deployment file. This account is used as temporary storage to download ADX database configuration scripts)

- deploy.sh: script to deploy the solution. THe only one you need to run 
- main.bicep: main Bicep deployment file. It includes all the other Bicep deployment files (modules)
- patientmonitoring.parameters.json: parameters file used to customize the deployment
- README.md: This README file
