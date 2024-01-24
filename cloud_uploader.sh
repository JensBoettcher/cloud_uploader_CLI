#! /bin/bash

# section for variables
groupLocation=germanywestcentral
groupName=rg-uploader
storageName=<"make sure the name doesn't exist global in azure">
tier=cool
containerName=uploadblob
mailAdresse=<"your mailadress">
subID=<"your subscription ID">

# login into your Azure account
az login
echo "You're logged in.

# create resourcegroup
az group create \
    --name $groupName \
    --location $groupLocation
echo "Resourcegroup created!"

# create storage account
if az storage account create --name $storageName \
    --resource-group $groupName \
    --location $groupLocation \
    --encryption-service blob \
    --kind StorageV2 \
    --access-tier $tier; then
    echo "Storage account created!"
else
    echo "Failed to create storage account."
fi
az storage account update \
    --name $storageName \
    --resource-group $groupName \
    --set minimumTlsVersion=TLS1_2

# add role access and deploy storage conatiner
az ad signed-in-user show \
    --query id -o tsv | az role assignment create \
    --role "Storage Blob Data Contributor" \
    --assignee $mailAdresse \
    --scope /subscriptions/$subID/resourceGroups/$groupName/providers/Microsoft.Storage/storageAccounts/$storageName/blobServices/default/containers/$containerName
echo "Role is set Storage Blob Data Contributor"

if az storage container create \
    --name $containerName \
    --account-name $storageName \
    --fail-on-exist \
    --auth-mode login; then
    echo "Storage container deployed."
else
    echo "Failed to deploy container."
fi

read -p "Do you want upload a file or an directory? (f/d)" uploadType

if [ "$uploadType" = "f" ]; then
    read -p "Type in the source path for the file:" filePath
    az storage blob upload \
        --account-name $storageName \
        --container-name $containerName \
        --name $filePath \
        --file $filePath \
        --type block \
        --auth-mode login
elif [ "$uploadType" = "d" ]; then
    read -p "Type in the source path for the directory:" folderPath
    az storage blob upload-batch \
        --account-name $storageName \
        --destination $containerName \
        --source $folderPath \
        --auth-mode login
else
    echo "Please type in 'f' for file upload or 'd' for directory upload."
fi
