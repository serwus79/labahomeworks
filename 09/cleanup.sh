#!/bin/bash

# Login to Azure (This will open a login prompt in your browser)
# az login

# Set variables for the Resource Group
resourceGroupName="labahw09"

# Check if the Resource Group exists
groupExists=$(az group exists --name $resourceGroupName)

if [ "$groupExists" = "true" ]; then
    echo "Resource group $resourceGroupName exists, deleting..."
    az group delete --name $resourceGroupName --yes --no-wait
    echo "Waiting for deletion to complete..."
    az group wait --name $resourceGroupName --deleted --timeout 300
else
    echo "Resource group $resourceGroupName does not exists..."
fi