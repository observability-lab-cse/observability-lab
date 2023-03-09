# Infrastructure

## Prerequisites

* [Install Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) (required version 2.20.0 or later)
* Sign in to the Azure CLI by using the `az login`

## Deployment

```bash
cd infrastructure
az group create --name <resource-group-name> --location <location>
az deployment group create --resource-group <resource-group-name> --template-file main.bicep --parameters projectName=<project-name>
```

Validate deployment by [connecting to the cluster](https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-bicep?tabs=azure-cli%2CCLI#connect-to-the-cluster).

## Connect AKS to ACR

```bash
az aks update --name <aks-cluster-name> --resource-group <resource-group-name> --attach-acr <acr-name>
```

## Cleanup

```bash
az group delete --name <resource-group-name>
```
