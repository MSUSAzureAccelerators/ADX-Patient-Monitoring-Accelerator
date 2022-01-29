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
    spinner "Installing IoT Extensions"
    deletePreLine
}

function deploy_azure_services() {
    (az deployment group create -n $deploymentName -g $rgName \
        --template-file main.bicep \
        --parameters deploymentSuffix=$randomNum principalId=$principalId @patientmonitoring.parameters.json \
        --only-show-errors --output none) &
    spinner "Installing IoT Extensions"
    deletePreLine
}

# Define required variables
randomNum=$RANDOM
currentDate=$(date)
tomorrow=$(date +"%Y-%m-%dT00:00:00Z" -d "$currentDate +1 days")
deploymentName=ADXConnectedDevicesDeployment$randomNum
rgName=ADXConnectedDevices$randomNum
principalId=$(az ad signed-in-user show --query objectId -o tsv)

# Show banner
banner 

echo '1. Starting solution deployment'
add_iot_extensions # Install/Update required eztensions
create_resource_group # Create parent resurce group
deploy_azure_services # Create all additional services using main Bicep template