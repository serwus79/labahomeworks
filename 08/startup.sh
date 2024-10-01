#!/bin/bash

# Login to Azure (This will open a login prompt in your browser)
# az login

# Set variables for the Resource Group
resourceGroupName="labahomework08"
location="WestEurope"
registryName="labahomework08registry$RANDOM"
aciName="labahomework08ContainerInstance"
imageName="labahomework/mygallery:latest"

# Check if the Resource Group exists
groupExists=$(az group exists --name $resourceGroupName)

if [ "$groupExists" = "true" ]; then
    echo "Resource group $resourceGroupName already exists. Exiting..."
    exit 1
fi

# Create the Resource Group
az group create --name $resourceGroupName --location $location
az acr create --resource-group $resourceGroupName --name $registryName --sku Basic --location $location


# Check if the Resource Group was created
# az group show --name $resourceGroupName

# Check if the Container Registry was created
# az acr show --name $registryName --resource-group $resourceGroupName

az acr login --name $registryName
docker tag $imageName $registryName.azurecr.io/$imageName
docker push $registryName.azurecr.io/$imageName


# Create a container instance using the image from ACR
az container create --resource-group $resourceGroupName --name $aciName \
    --image $registryName.azurecr.io/$imageName --cpu 1 --memory 1 \
    --registry-login-server $registryName.azurecr.io --registry-username $registryName \
    --registry-password $(az acr credential show --name $registryName --query "passwords[0].value" -o tsv) \
    --dns-name-label $aciName-$location --location $location

# Check if the Container Instance was created
az container show --resource-group $resourceGroupName --name $aciName --query "{ProvisioningState:provisioningState, FQDN:ipAddress.fqdn}"

# List the repositories in the registry
az acr repository list --name $registryName --output table