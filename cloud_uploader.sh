#!/bin/bash

echo "Welcome to the cloud uploader. This script will help you upload files quickly to an Azure storage solution."

#ANCHOR - log into the azure account
#az login

#ANCHOR - variable section
resource_group="storage_group"
storage_account="storage202311200"
subscription_id="a4382a28-de0e-4825-b036-9b96b837f5e3"
blob_container="blob20231116"

#ANCHOR - resource-group section
az group create \
    --name $resource_group \
    --location germanywestcentral

echo "Create your resource-group."

#ANCHOR - storage section
#NOTE - create storage account
az storage account create \
    --name $storage_account \
    --resource-group $resource_group \
    --location germanywestcentral \
    --access-tier Cool \
    --allow-blob-public-access true \
    --sku Standard_LRS \
    --encryption-services blob

echo "The storage account creation is in progress."

#NOTE - create the blob storage container
#NOTE - set storage blob data contributor
az ad signed-in-user show --query id -o tsv | az role assignment create \
    --role "Storage Blob Data Contributor" \
    --assignee @- \
    --scope "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Storage/storageAccounts/$storage_account"

echo "Blob storage contributor role added."

#NOTE - create the container
az storage container create \
    --account-name $storage_account \
    --name $blob_container \
    --auth-mode login

echo "Blob Container created."