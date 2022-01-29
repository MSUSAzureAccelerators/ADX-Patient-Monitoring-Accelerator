#!/bin/bash

# Helper Functions
function banner() {
    clear
    echo '           _______   __           _____      _   _            _    '
    echo '     /\   |  __ \ \ / /          |  __ \    | | (_)          | |   '
    echo '    /  \  | |  | \ V /   ______  | |__) |_ _| |_ _  ___ _ __ | |_  '
    echo "   / /\ \ | |  | |> <   |______| |  ___/ _\` | __| |/ _ \ '_ \| __| "
    echo '  / ____ \| |__| / . \           | |  | (_| | |_| |  __/ | | | |_  '
    echo ' /_/    \_\_____/_/_\_\          |_|   \__,_|\__|_|\___|_| |_|\__| '
    echo '        |__   __| | |                   | |                        '
    echo '           | | ___| | ___ _ __ ___   ___| |_ _ __ _   _            '
    echo "           | |/ _ \ |/ _ \ '_ \` _ \ / _ \ __| '__| | | |           "
    echo '           | |  __/ |  __/ | | | | |  __/ |_| |  | |_| |           '
    echo '           |_|\___|_|\___|_| |_| |_|\___|\__|_|   \__, |           '
    echo '                                                   __/ |           '
    echo '                                                  |___/            '
}

function spinner() {
    local info="$1"
    local pid=$!
    local delay=0.75
    local spinstr='|/-\'
    while kill -0 $pid 2> /dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  $info" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        echo -ne "\033[0K\r"
    done
}

function deletePreLine() {
    echo -ne '\033[1A'
    echo -ne "\r\033[0K"
}

# Service Specific Functions
function add_iot_extensions() {
    (az extension add --name azure-iot --only-show-errors --output none; \
    az extension update --name azure-iot --only-show-errors --output none)
    spinner "Installing IoT Extensions"
    deletePreLine
}

function create_resource_group() {
    (az group create --name $rgName --location "East US" --only-show-errors --output none)
    spinner "Creating Resource Gorup"
    deletePreLine
}

function deploy_azure_services() {
    (az deployment group create -n $deploymentName -g $rgName \
        --template-file main.bicep \
        --parameters deploymentSuffix=$randomNum principalId=$principalId @patientmonitoring.parameters.json \
        --only-show-errors --output none) &
    spinner "Deploying Azure Services"
    deletePreLine
}

function configure_ADX_cluster() {
    (sed -i "s/<dtURI>/$dtHostName/g" config/configDB.kql ;\
    az storage blob upload -f config/configDB.kql -c adxscript -n configDB.kql --account-key $saKey --account-name $saName --only-show-errors --output none  ;\
    blobURI="https://$saName.blob.core.windows.net/adxscript/configDB.kql"  ;\
    blobSAS=$(az storage blob generate-sas --account-name $saName --container-name adxscript --name configDB.kql --permissions acdrw --expiry $tomorrow --account-key $saKey --output tsv)  ;\
    az kusto script create --cluster-name $adxName --database-name PatientMonitoring --force-update-tag "config1" --script-url $blobURI --script-url-sas-token $blobSAS --resource-group $rgName --name 'configDB' --only-show-errors --output none  ;\
    az kusto data-connection event-hub create --cluster-name $adxName --name "PatientMonitoring" --database-name "PatientMonitoring" --location $location --consumer-group '$Default' --event-hub-resource-id $eventHubResourceId --managed-identity-resource-id $adxResoureId --data-format 'JSON' --table-name 'TelemetryRaw' --mapping-rule-name 'TelemetryRaw_mapping' --compression 'None' --resource-group $rgName ) &
    spinner "Configuring ADX Cluster"
    deletePreLine
}

function create_digital_twin_models() {
    (az dt model create -n $dtName --from-directory ./dtconfig   ;\
    az dt twin create -n $dtName --dtmi "dtmi:PatientMonitoring:Facility;1" --twin-id Arkham ;\
    az dt twin create -n $dtName --dtmi "dtmi:PatientMonitoring:Department;1" --twin-id Rehabilitation ;\
    az dt twin create -n $dtName --dtmi "dtmi:PatientMonitoring:Department;1" --twin-id Psychology ;\
    az dt twin relationship create -n $dtName --relationship-id 'containsRehab' --relationship 'facilitycontainsdepartment' --source 'Arkham' --target 'Rehabilitation' ;\
    az dt twin relationship create -n $dtName --relationship-id 'containsPsychology' --relationship 'facilitycontainsdepartment' --source 'Arkham' --target 'Psychology' ) &
    spinner "Creating model for Azure Digital Twins $dtName"
    deletePreLine
}

function deploy_smart_kneww_devices() {
    for (( c=1; c<=$smartKneeBraceDevices; c++ ))
    do
        deviceId=$(cat /proc/sys/kernel/random/uuid)
        az iot central device create --device-id $deviceId --app-id $iotCentralAppID --template dtmi:j71gm4wvkse:q2hnw2dwt --simulated --only-show-errors --output none
        if ((c%2)); then
        department=${departments[0]}
        patient=${rehapPatients[c%3]}
        else
        department=${departments[1]}
        patient=${psychPatients[c%3]}
        fi    
        (az dt twin create -n $dtName --dtmi "dtmi:PatientMonitoring:KneeBrace;1" --twin-id $deviceId --properties "{'PatientId': '${patient}'}" --only-show-errors --output none ;\
        az dt twin relationship create -n $dtName --relationship-id "owns${deviceId}" --relationship 'departmentownsdevice' --source $department --target $deviceId --only-show-errors --output none) &
        spinner "Creating $smartKneeBraceDevices Smart Knee Brace devices on IoT Central: $iotCentralName ($iotCentralAppID) and Digital Twins: $dtName"
        deletePreLine
    done
}

function deploy_vitals_patch_devices() {
    for (( c=1; c<=$vitalPatchDevices; c++ ))
    do
        deviceId=$(cat /proc/sys/kernel/random/uuid)
        az iot central device create --device-id $deviceId --app-id $iotCentralAppID --template dtmi:hpzy1kfcbt2:umua7dplmbd --simulated --only-show-errors --output none

        if ((c%2)); then
        department=${departments[0]}
        patient=${rehapPatients[c%3]}
        else
        department=${departments[1]}
        patient=${psychPatients[c%3]}
        fi 
        (az dt twin create -n $dtName --dtmi "dtmi:PatientMonitoring:VirtualPatch;1" --twin-id $deviceId --properties "{'PatientId': '${patient}'}" ;\
        az dt twin relationship create -n $dtName --relationship-id "owns${deviceId}" --relationship 'departmentownsdevice' --source $department --target $deviceId --only-show-errors --output none ) &
        spinner "Creating $vitalPatchDevices Vitals Patch devices on IoT Central: $iotCentralName ($iotCentralAppID) and Digital Twins: $dtName"
        deletePreLine
    done
}

function configure_IoT_Central_output() {
    (az iot central export destination create --app-id $iotCentralAppID --dest-id 'eventHubExport' --type eventhubs@v1 --name 'eventHubExport' --authorization '{"type": "connectionString", "connectionString": "'$eventHubConnectionString'" }' --output none  ;\
    az iot central export create --app-id $iotCentralAppID --export-id 'iotEventHubExport' --display-name 'iotEventHubExport' --source 'telemetry' --destinations '[{"id": "eventHubExport"}]' --output none) &
    spinner " Creating IoT Central App export and destination on IoT Central: $iotCentralName ($iotCentralAppID)"
    deletePreLine
}

# Define required variables
randomNum=$RANDOM
currentDate=$(date)
tomorrow=$(date +"%Y-%m-%dT00:00:00Z" -d "$currentDate +1 days")
deploymentName=ADXConnectedDevicesDeployment$randomNum
rgName=ADXConnectedDevices$randomNum
principalId=$(az ad signed-in-user show --query objectId -o tsv)

# Setup array to utilize when assiging devices to departments and patients
departments=('Rehabilitation' 'Psychology')
rehapPatients=('Patient1' 'Patient2' 'Patient3')
psychPatients=('Patient4' 'Patient5' 'Patient6')

banner # Show Welcome banner

echo '1. Starting solution deployment'
add_iot_extensions # Install/Update required eztensions
create_resource_group # Create parent resurce group
deploy_azure_services # Create all additional services using main Bicep template

echo "2. Starting configuration for deployment $deploymentName"
# Get Deployment output values
dtName=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.digitalTwinName.value --output tsv)
dtHostName=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.digitalTwinHostName.value --output tsv)
saName=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.saName.value --output tsv)
saKey=$(az storage account keys list --account-name $saName --query [0].value -o tsv)
adxName=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.adxName.value --output tsv)
adxResoureId=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.adxClusterId.value --output tsv)
location=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.location.value --output tsv)
eventHubNSId=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.eventhubClusterId.value --output tsv)
eventHubResourceId="$eventHubNSId/eventhubs/PatientMonitoring"
iotCentralName=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.iotCentralName.value --output tsv)
iotCentralAppID=$(az iot central app show -n $iotCentralName -g $rgName --query  applicationId --output tsv)
smartKneeBraceDevices=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.smartKneeBraceDeviceNumber.value --output tsv)
vitalPatchDevices=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.vitalPatchDevicesNumber.value --output tsv)
eventHubConnectionString=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.eventHubConnectionString.value --output tsv)

# Start Configuration
configure_ADX_cluster # Configure ADX cluster
create_digital_twin_models # Create all the models from folder in git repo

# Get/Refresh IoT Central Token 
az account get-access-token --resource https://apps.azureiotcentral.com --only-show-errors --output none

# Complete configuration
deploy_smart_kneww_devices # Deploy Smart Knee Brace simulated devices
deploy_vitals_patch_devices # Deploy Vitals Patch Simulated devices
configure_IoT_Central_output # On IoT Central, create an Event Hub export and destination with json payload

echo "3. Configuration completed"