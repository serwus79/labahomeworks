#!/bin/bash

# Login to Azure (This will open a login prompt in your browser)
# az login

# Set variables for the Resource Group
resourceGroupName="labahomework08"
location="WestEurope"
registryName="labahomework08registry$RANDOM"
registryName="labahomework08registry11975"
aciName="labahomework08ContainerInstance"
imageName="labahomework/mygallery:latest"

# Check if the Resource Group exists
# groupExists=$(az group exists --name $resourceGroupName)

# if [ "$groupExists" = "true" ]; then
#     echo "Resource group $resourceGroupName exists, deleting..."
#     az group delete --name $resourceGroupName --yes --no-wait
#     echo "Waiting for deletion to complete..."
#     az group wait --name $resourceGroupName --deleted --timeout 300
# fi
# if [ "$groupExists" = "true" ]; then
#     echo "Resource group $resourceGroupName already exists. Exiting..."
#     exit 1
# fi

# Create the Resource Group
az group create --name $resourceGroupName --location $location
# # Create Container Registry
az acr create --resource-group $resourceGroupName --name $registryName \
  --sku Basic --location $location --public-network-enabled true
  --public-network-enabled true


# Check if the Resource Group was created
# az group show --name $resourceGroupName

# Check if the Container Registry was created
az acr show --name $registryName --resource-group $resourceGroupName

# az acr login --name $registryName
# docker tag $imageName $registryName.azurecr.io/$imageName
# docker push $registryName.azurecr.io/$imageName