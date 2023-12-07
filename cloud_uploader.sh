#!/bin/bash

echo "Welcome to the cloud uploader. This script will help you upload files quickly to an Azure storage solution."


#ANCHOR - variable section
resource_group="storage_group"
location="germanywestcentral"
storage_account="storage202311200"
subscription_id="a4382a28-de0e-4825-b036-9b96b837f5e3"
blob_container="blob20231116"


#ANCHOR - log into the azure account
az login


#ANCHOR - resource-group section
az group create \
    --name $resource_group \
    --location $location

echo "Deploy your resource-group."

#ANCHOR - storage section
#NOTE - create storage account
az storage account create \
    --name $storage_account \
    --resource-group $resource_group \
    --location $location \
    --access-tier Cool \
    --allow-blob-public-access true \
    --sku Standard_LRS \
    --encryption-services blob

echo "The storage account deployment is in progress."

#NOTE - set the Azure account owner to storage blob data contributor (you must add a blob data contributor even if you are the owner of the account)
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

echo "Blob Container deployed."

read -p "Do want upload a file now?(y/n) " upload
if [ $upload == "y" ]; then
    read -p "Type in a name for the file you like to upload. " file_name
    read -p "Type in the path to the file you would like to upload. " file_path
    az storage blob upload \
        --account-name $storage_account \
        --container-name $blob_container \
        --name $file_name \
        --file $file_path \
        --auth-mode login
else
    echo "Ok you can come back and upload a file at any time."
    return
fi