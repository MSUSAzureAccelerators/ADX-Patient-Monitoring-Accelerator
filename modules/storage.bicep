param saname string
param location string = resourceGroup().location

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  kind: 'StorageV2'
  location: location
  name: saname
  sku: {
    name: 'Standard_LRS'
  }
  properties: {}
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  name: '${saname}/default/adxscript'
  dependsOn: [
    storageaccount
  ]
}

output saName string = storageaccount.name
