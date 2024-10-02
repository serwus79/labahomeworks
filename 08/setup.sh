#!/bin/bash

# Colors
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Set variables for the Resource Group and other resources
resourceGroupName="labahw08"
location="WestEurope"
location="PolandCentral"
registryName="${resourceGroupName}registry$RANDOM"
aciName="${resourceGroupName}containerinstance"
imageName="labahomeworknginx"
storageAccountName="${resourceGroupName}strg${RANDOM}"
storageAccountName=${storageAccountName:0:24}
shareName="imageshare"

# Login to Azure
echo -e "${YELLOW}Logging in to Azure...${NC}"
# az login

# Create Resource Group
echo -e "${YELLOW}Creating Resource Group: $resourceGroupName...${NC}"
az group create --name $resourceGroupName --location $location

# Create Azure Container Registry
echo -e "${YELLOW}Creating Azure Container Registry with admin user enabled...${NC}"
az acr create --resource-group $resourceGroupName --name $registryName --sku Basic --location $location --public-network-enabled true --admin-enabled true

# Create Storage Account
echo -e "${YELLOW}Creating Storage Account: $storageAccountName...${NC}"
az storage account create --name $storageAccountName --resource-group $resourceGroupName --location $location --sku Standard_LRS

# Get Storage Account Key
echo -e "${YELLOW}Retrieving Storage Account Key...${NC}"
storageAccountKey=$(az storage account keys list --resource-group $resourceGroupName --account-name $storageAccountName --query "[0].value" -o tsv)

# Create a file share
echo -e "${YELLOW}Creating File Share: $shareName...${NC}"
az storage share create --name $shareName --account-name $storageAccountName

# Register Microsoft.ContainerInstance provider
echo -e "${YELLOW}Registering the Microsoft.ContainerInstance provider...${NC}"
az provider register --namespace Microsoft.ContainerInstance

echo -e "${YELLOW}Waiting for provider registration to complete...${NC}"
while [[ $(az provider show --namespace Microsoft.ContainerInstance --query "registrationState" -o tsv) != "Registered" ]]; do
    echo -e "${YELLOW}Still waiting for provider registration to complete...${NC}"
    sleep 10
done
echo -e "${YELLOW}Provider registered.${NC}"

# Login to Azure Container Registry
echo -e "${YELLOW}Logging in to Azure Container Registry...${NC}"
az acr login --name $registryName

echo -e "${YELLOW}Building image in ACR...${NC}"
az acr build --registry $registryName --image $imageName:latest ./nginx

# Retrieve the ACR admin username and password
echo -e "${YELLOW}Retrieving the ACR admin username and password...${NC}"
acrUsername=$(az acr credential show --name $registryName --query "username" -o tsv)
acrPassword=$(az acr credential show --name $registryName --query "passwords[0].value" -o tsv)

# Creating a container instance
echo -e "${YELLOW}Creating a container instance...${NC}"
az container create --resource-group $resourceGroupName --name $aciName \
    --image $registryName.azurecr.io/$imageName --cpu 1 --memory 1 \
    --registry-login-server $registryName.azurecr.io --registry-username $acrUsername --registry-password $acrPassword \
    --azure-file-volume-account-name $storageAccountName --azure-file-volume-account-key $storageAccountKey \
    --azure-file-volume-share-name $shareName --azure-file-volume-mount-path /usr/share/nginx/html/share \
    --dns-name-label $aciName-$location --location $location --ports 80

# Checking if the Container Instance was created
echo -e "${YELLOW}Checking if the Container Instance was created...${NC}"
az container show --resource-group $resourceGroupName --name $aciName --query "{ProvisioningState:provisioningState, FQDN:ipAddress.fqdn}"

# Listing the repositories in the registry
echo -e "${YELLOW}Listing the repositories in the registry...${NC}"
az acr repository list --name $registryName --output table

# Some informations
echo -e "${YELLOW}For attach to container console use:${NC}"
echo "az container attach --resource-group $resourceGroupName --name $aciName"
echo -e "${YELLOW}For attach to container logs use:${NC}"
echo "az container logs --resource-group $resourceGroupName --name $aciName"
