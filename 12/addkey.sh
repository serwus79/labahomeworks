#!/bin/bash

# Zmienne
keyVaultName="Laba12KeyVault"
resourceGroupName="labahw12kvault"
keyName="Laba12Key"

# Utworzenie klucza w Azure Key Vault
echo "Tworzenie klucza $keyName w Key Vault $keyVaultName..."
az keyvault key create --vault-name $keyVaultName --name $keyName --protection software

# Sprawdzenie, czy klucz został utworzony
echo "Lista kluczy w Key Vault $keyVaultName:"
az keyvault key list --vault-name $keyVaultName --query "[].{name:name}" --output table
