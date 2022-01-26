#!/bin/bash

echo "1. Starting configuration for deployment $deploymentName"
# Get Digital Twins instance name
dtName=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.digitalTwinName.value --output tsv)

# Create all the models from folder in git repo
echo "2. Creating model for Azure Digital Twins $dtName"
az dt model create -n $dtName --from-directory ./dtconfig
az dt twin create -n $dtName --dtmi "dtmi:PatientMonitoring:Facility;1" --twin-id Arkham
az dt twin create -n $dtName --dtmi "dtmi:PatientMonitoring:Department;1" --twin-id Rehabilitation
az dt twin create -n $dtName --dtmi "dtmi:PatientMonitoring:Department;1" --twin-id Psychology
az dt twin relationship create -n $dtName --relationship-id 'contains' --relationship 'facilitycontainsdepartment' --source 'Arkham' --target 'Rehabilitation'
az dt twin relationship create -n $dtName --relationship-id 'contains' --relationship 'facilitycontainsdepartment' --source 'Arkham' --target 'Psychology'

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
echo "3. Creating $smartKneeBraceDevices Smart Knee Brace devices on IoT Central: $iotCentralName ($iotCentralAppID) and Digital Twins: $dtName"
for (( c=1; c<=$smartKneeBraceDevices; c++ ))
do
    deviceId=$(cat /proc/sys/kernel/random/uuid)
    az iot central device create --device-id $deviceId --app-id $iotCentralAppID --template dtmi:j71gm4wvkse:q2hnw2dwt --simulated --only-show-errors --output none
    if ((c%2)); then
	department=${departments[0]}
	patient=${rehapPatients[c%3]}
    else
	department=${test[1]}
	patient=${psychPatients[c%3]}
    fi    
	az dt twin create -n $dtName --dtmi "dtmi:PatientMonitoring:KneeBrace;1" --twin-id $deviceId --properties "{'PatientId': '${patient}'}" --only-show-errors --output none
	az dt twin relationship create -n $dtName --relationship-id "owns${deviceId}" --relationship 'departmentownsdevice' --source $department --target $deviceId --only-show-errors --output none
	echo "   Device #$c with id:$deviceId created for patient $patient and linked to $department department"
done
 
# DeployVitals Patch Simulated devices
#vitalPatchDevices=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.vitalPatchDevicesNumber.value)
echo "4. Creating $vitalPatchDevices Vitals Patch devices on IoT Central: $iotCentralName ($iotCentralAppID) and Digital Twins: $dtName"
for (( c=1; c<=$vitalPatchDevices; c++ ))
do
    deviceId=$(cat /proc/sys/kernel/random/uuid)
    az iot central device create --device-id $deviceId --app-id $iotCentralAppID --template dtmi:hpzy1kfcbt2:umua7dplmbd --simulated --only-show-errors --output none
    if ((c%2)); then
	department=${departments[0]}
	patient=${rehapPatients[c%3]}
    else
	department=${test[1]}
	patient=${psychPatients[c%3]}
    fi 
	az dt twin create -n $dtName --dtmi "dtmi:PatientMonitoring:VirtualPatch;1" --twin-id $deviceId --properties "{'PatientId': '${patient}'}"
	az dt twin relationship create -n $dtName --relationship-id "owns${deviceId}" --relationship 'departmentownsdevice' --source $department --target $deviceId
	echo "   Device #$c with id:$deviceId created for patient $patient and linked to $department department"
done

# On IoT Central, create an Event Hub export destination with json payload
echo "5. Creating Event Hub export destination on IoT Central: $iotCentralName ($iotCentralAppID)"
eventHubConnectionString=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.eventHubConnectionString.value --output tsv)
az iot central export destination create --app-id $iotCentralAppID --dest-id 'eventHubExport' --type eventhubs@v1 --name 'eventHubExport' --authorization '{"type": "connectionString", "connectionString": "'$eventHubConnectionString'" }' --output none

# Create IoT Central App Export using previoulsy created destination
echo "6. Creating IoT Central App Export on IoT Central: $iotCentralName ($iotCentralAppID)"
az iot central export create --app-id $iotCentralAppID --export-id 'iotEventHubExport' --display-name 'iotEventHubExport' --source 'telemetry' --destinations '[{"id": "eventHubExport"}]' --output none

echo "7. Configuration completed"