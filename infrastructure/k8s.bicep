@description('The name of the Managed Cluster resource.')
param clusterName string

@description('The location of the Managed Cluster resource.')
param location string

@description('DNS prefix to use with hosted Kubernetes API server FQDN.')
param dnsPrefix string

@description('Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0

@description('The number of nodes for the cluster.')
@minValue(1)
@maxValue(50)
param agentCount int = 2

@description('The size of the Virtual Machine.')
param agentVMSize string = 'Standard_B2ms'

@description('The name of the Log Analytics workspace linked to AKS')
@minLength(1)
param logAnalyticsWorkspaceId string

resource aks 'Microsoft.ContainerService/managedClusters@2022-05-02-preview' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: osDiskSizeGB
        count: agentCount
        vmSize: agentVMSize
        osType: 'Linux'
        mode: 'System'
      }
    ]
    addonProfiles: {
          omsAgent: {
            enabled: true
            config: {
              logAnalyticsWorkspaceResourceID: logAnalyticsWorkspaceId
            }
          }
          azureKeyvaultSecretsProvider: {
            enabled: true
            config: {
              enableSecretRotation: 'true'
              rotationPollInterval: '2m'
            }
          }
        }
  }
}

output clusterName string = aks.name
output kubeletIdentityId string = aks.properties.identityProfile.kubeletidentity.objectId
output clusterKeyVaultSecretProviderObjectId string = aks.properties.addonProfiles.azureKeyvaultSecretsProvider.identity.objectId
output clusterKeyVaultSecretProviderClientId string = aks.properties.addonProfiles.azureKeyvaultSecretsProvider.identity.clientId