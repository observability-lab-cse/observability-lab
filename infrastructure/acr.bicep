@description('Globally unique name of your Azure Container Registry')
param acrName string

@description('The location for the registry.')
param location string

resource acrResource 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
  }
}

output acrName string = acrResource.name
