#!/bin/bash

currentDate=$(date)
tomorrow=$(date +"%Y-%m-%dT00:00:00Z" -d "$currentDate +1 days")

echo "1. Starting configuration for deployment $deploymentName"
# Get Digital Twins instance name
dtName=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.digitalTwinName.value --output tsv)
dtHostName=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.digitalTwinHostName.value --output tsv)
saName=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.saName.value --output tsv)
saKey=$(az storage account keys list --account-name $saName --query [0].value -o tsv)
adxName=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.adxName.value --output tsv)
adxResoureId=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.adxClusterId.value --output tsv)
location=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.location.value --output tsv)
eventHubNSId=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.eventhubClusterId.value --output tsv)
eventHubResourceId="$eventHubNSId/eventhubs/PatientMonitoring"

# Modify kql script
echo "2. Modifying KQL script"
sed -i "s/<dtURI>/$dtHostName/g" config/configDB.kql
az storage blob upload -f config/configDB.kql -c adxscript -n configDB.kql --account-key $saKey --account-name $saName --only-show-errors --output none

# Configure ADX Cluster
echo "3. Running script to configure Azure Data Explorer"
blobURI="https://$saName.blob.core.windows.net/adxscript/configDB.kql"
blobSAS=$(az storage blob generate-sas --account-name $saName --container-name adxscript --name configDB.kql --permissions acdrw --expiry $tomorrow --account-key $saKey --output tsv)
az kusto script create --cluster-name $adxName --database-name PatientMonitoring --force-update-tag "config1" --script-url $blobURI --script-url-sas-token $blobSAS --resource-group $rgName --name 'configDB' --only-show-errors --output none
az kusto data-connection event-hub create --cluster-name $adxName --name "PatientMonitoring" --database-name "PatientMonitoring" --location $location --consumer-group '$Default' --event-hub-resource-id $eventHubResourceId --managed-identity-resource-id $adxResoureId --data-format 'JSON' --table-name 'TelemetryRaw' --mapping-rule-name 'TelemetryRaw_mapping' --compression 'None' --resource-group $rgName

# Create all the models from folder in git repo
echo "4. Creating model for Azure Digital Twins $dtName"
az dt model create -n $dtName --from-directory ./dtconfig
az dt twin create -n $dtName --dtmi "dtmi:PatientMonitoring:Facility;1" --twin-id Arkham
az dt twin create -n $dtName --dtmi "dtmi:PatientMonitoring:Department;1" --twin-id Rehabilitation
az dt twin create -n $dtName --dtmi "dtmi:PatientMonitoring:Department;1" --twin-id Psychology
az dt twin relationship create -n $dtName --relationship-id 'containsRehab' --relationship 'facilitycontainsdepartment' --source 'Arkham' --target 'Rehabilitation'
az dt twin relationship create -n $dtName --relationship-id 'containsPsychology' --relationship 'facilitycontainsdepartment' --source 'Arkham' --target 'Psychology'

# Setup array to utilize when assiging devices to departments and patients
departments=('Rehabilitation' 'Psychology')
rehapPatients=('Patient1' 'Patient2' 'Patient3')
psychPatients=('Patient4' 'Patient5' 'Patient6')

# Get IoT Central app ID from previous deployment:
iotCentralName=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.iotCentralName.value --output tsv)
iotCentralAppID=$(az iot central app show -n $iotCentralName -g $rgName --query  applicationId --output tsv)

# Get IoT Central Token 
az account get-access-token --resource https://apps.azureiotcentral.com --only-show-errors --output none

smartKneeBraceDevices=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.smartKneeBraceDeviceNumber.value --output tsv)
vitalPatchDevices=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.vitalPatchDevicesNumber.value --output tsv)

# Deploy Smart Knee Brace imulated devices
#smartKneeBraceDevices=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.smartKneeBraceDeviceNumber.value --output tsv)
echo "5. Creating $smartKneeBraceDevices Smart Knee Brace devices on IoT Central: $iotCentralName ($iotCentralAppID) and Digital Twins: $dtName"
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
	az dt twin create -n $dtName --dtmi "dtmi:PatientMonitoring:KneeBrace;1" --twin-id $deviceId --properties "{'PatientId': '${patient}'}" --only-show-errors --output none
	echo "   Device $c with id:$deviceId created for patient $patient and linked to $department department"
	az dt twin relationship create -n $dtName --relationship-id "owns${deviceId}" --relationship 'departmentownsdevice' --source $department --target $deviceId --only-show-errors --output none
	
done
 
# DeployVitals Patch Simulated devices
#vitalPatchDevices=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.vitalPatchDevicesNumber.value)
echo "6. Creating $vitalPatchDevices Vitals Patch devices on IoT Central: $iotCentralName ($iotCentralAppID) and Digital Twins: $dtName"
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
	az dt twin create -n $dtName --dtmi "dtmi:PatientMonitoring:VirtualPatch;1" --twin-id $deviceId --properties "{'PatientId': '${patient}'}"
	az dt twin relationship create -n $dtName --relationship-id "owns${deviceId}" --relationship 'departmentownsdevice' --source $department --target $deviceId --only-show-errors --output none
	echo "   Device #$c with id:$deviceId created for patient $patient and linked to $department department"
done

# On IoT Central, create an Event Hub export destination with json payload
echo "7. Creating Event Hub export destination on IoT Central: $iotCentralName ($iotCentralAppID)"
eventHubConnectionString=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.eventHubConnectionString.value --output tsv)
az iot central export destination create --app-id $iotCentralAppID --dest-id 'eventHubExport' --type eventhubs@v1 --name 'eventHubExport' --authorization '{"type": "connectionString", "connectionString": "'$eventHubConnectionString'" }' --output none

# Create IoT Central App Export using previoulsy created destination
echo "8. Creating IoT Central App Export on IoT Central: $iotCentralName ($iotCentralAppID)"
az iot central export create --app-id $iotCentralAppID --export-id 'iotEventHubExport' --display-name 'iotEventHubExport' --source 'telemetry' --destinations '[{"id": "eventHubExport"}]' --output none

echo "9. Configuration completed"