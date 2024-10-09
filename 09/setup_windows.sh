#!/bin/bash

# Setup file for laba homework 9

# Colors
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Set variables for the Resource Group and other resources
resourceGroupName="labahw09wind"
location="PolandCentral"
registryName="${resourceGroupName}registry"
aciName="${resourceGroupName}containerinstance"
aksClusterName="${resourceGroupName}kscluster"
imageName="labahomeworkwinhello"
windowsAdminUsername="localadmin"
windowsAdminPassword="..."
# Array of required providers
requiredProviders=("Microsoft.ContainerService")

# Login to Azure (uncomment if required)
#echo -e "${YELLOW}Logging in to Azure...${NC}"
#az login

# Create Resource Group
echo -e "${YELLOW}Creating Resource Group: $resourceGroupName...${NC}"
az group create --name $resourceGroupName --location $location

# Create Azure Container Registry
echo -e "${YELLOW}Creating Azure Container Registry with admin user enabled...${NC}"
az acr create --resource-group $resourceGroupName --name $registryName --sku Basic --location $location --admin-enabled true

# Login to Azure Container Registry
echo -e "${YELLOW}Logging in to Azure Container Registry...${NC}"
az acr login --name $registryName

echo -e "${YELLOW}Building image in ACR...${NC}"
az acr build --registry $registryName --image $imageName:latest --platform windows ./HelloWorld

# Replace registry name and image name in aks deployment file
echo -e "${YELLOW}Replace registry name and image name in aks deployment file...${NC}"
sed "s/ACR_NAME/$registryName/" ./deployment/windows.yaml.source > ./deployment/windows.yaml
sed -i "" "s/IMG_NAME/$imageName/" ./deployment/windows.yaml

# Creating AKS cluster and attach ACR
echo -e "${YELLOW}Creating AKS: $aksClusterName and attaching ACR...${NC}"

az aks create \
  --resource-group $resourceGroupName \
  --name $aksClusterName \
  --network-plugin azure \
  --windows-admin-username $windowsAdminUsername \
  --windows-admin-password $windowsAdminPassword \
  --node-count 2 \
  --vm-set-type VirtualMachineScaleSets \
  --generate-ssh-keys \
  --attach-acr $registryName

echo -e "${YELLOW}Creating windows nodepool...${NC}"
az aks nodepool add \
    --resource-group $resourceGroupName \
    --cluster-name $aksClusterName \
    --os-type Windows \
    --name npwin \
    --node-count 1


echo -e "${YELLOW}Retrieving the AKS credentials...${NC}"
az aks get-credentials --resource-group $resourceGroupName --name $aksClusterName

echo -e "${YELLOW}Applying windows deployment...${NC}"
kubectl apply -f ./deployment/windows.yaml

echo -e "${YELLOW}Setting up HPA autoscaling for the application...${NC}"
kubectl autoscale deployment "${imageName}-deployment" --cpu-percent=50 --min=1 --max=10

echo -e "${YELLOW}Listing the repositories in the registry...${NC}"
az acr repository list --name $registryName --output table

echo -e "${YELLOW}List of nodes...${NC}"
kubectl get nodes
echo -e "${YELLOW}List of services...${NC}"
kubectl get svc
echo -e "${YELLOW}Confirm autoscaler setup...${NC}"
kubectl get hpa
