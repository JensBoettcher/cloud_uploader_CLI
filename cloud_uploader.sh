#!/bin/bash

echo "Welcome to the cloud uploader. This script will help you upload files quickly to an Azure storage solution."

#ANCHOR - log into the azure account
#az login

#ANCHOR - variable section
resource_group="storage_group"
storage_account="storage20231116"
blob_container="blob20231116"

#ANCHOR - resource-group section
az group create \
    --name $resource_group \
    --location germanywestcentral


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

#NOTE - create the blob storage container

