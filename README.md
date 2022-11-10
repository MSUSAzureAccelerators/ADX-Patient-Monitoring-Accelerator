![MSUS Solution Accelerator](./images/MSUS%20Solution%20Accelerator%20Banner%20Two_981.png)

# ADX Patient Monitoring Accelerator

![alt tag](./assets/AutomationPresentation.gif)

This example shows how to use ADX connected devices to monitor a patient's vitals and knee brace readings. It leverages (Azure Bicep)[https://docs.microsoft.com/EN-US/azure/azure-resource-manager/bicep/] and the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/) to automate the entire deployment.

The accelerator uses [Azure IoT Central](https://azure.microsoft.com/en-us/services/iot-central/) Continuous Patient Monitoring [application](https://docs.microsoft.com/en-us/azure/iot-central/core/concepts-app-templates#continuous-patient-monitoring) to generate telemetry readings for two IoT Consumer devices: automated knee brace and a vitals monitor patch. The generated data is automatically send to an [Azure Event Hub](https://azure.microsoft.com/en-us/services/event-hubs/) and then send to an [Azure Data Explorer](https://azure.microsoft.com/en-us/services/data-explorer/) for analysis.

An [Azure Digital Twins](https://azure.microsoft.com/en-us/services/digital-twins/) service is used to store additional simulated devices metadata.

The Azure Data Explorer cluster is configured with a database, a set of tables to store telemetry data from both devices, and a set of functions to parse incoming data and to query data directly from the Azure Digital Twins service.

The accelerator includes a [Power BI](https://powerbi.microsoft.com/en-us/) report to visualize the data. Just download the [file](/assets/Connected_Devices.pbix) and open it in Power BI.  

## Deployment instructions

On the [Azure Cloud Shell](https://shell.azure.com/) run the following commands to deploy the accelerator:
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
    git clone https://github.com/MSUSSolutionAccelerators/ADX-Patient-Monitoring-Solution-Accelerator.git
    ```
    Optionally, You can update the patientmonitoring.parameters.json file to personalize your deployment.

4. Deploy solution
    ```bash
    cd ADX-Patient-Monitoring-Solution-Accelerator
    . ./deploy.sh
    ```

5. Finally, download the [Power BI report](/assets/Connected_Devices.pbix), update the data source to point to your newly deployed Azure Data Explorer database, and refresh the data in the report.

## Exploring the data

If you wish to take a deeper look at the data feel free to explore using KQL. Here are some sample queries to get you started! [KQL Sample](kqlsample/Sample.kql)

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

- deploy.sh: script to deploy the solution. The only one you need to run 
- main.bicep: main Bicep deployment file. It includes all the other Bicep deployment files (modules)
- patientmonitoring.parameters.json: parameters file used to customize the deployment
- README.md: This README file

## License
Copyright (c) Microsoft Corporation

All rights reserved.

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ""Software""), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE


## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
