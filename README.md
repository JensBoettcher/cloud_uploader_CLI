**CloudUploader_Cli.sh**

This Bash script allows you to create an Azure resource group and a storage account, add a role to the signed in user for storage access, and then upload either a file or a directory to a blob container.

Usage:
1. Open the script file with an editor and add the missing variable informations. (marked with <>) Save the changes.
2. Run the script in your terminal: (./CloudUploader_Cli.sh)
3. The script will then create the resource group and storage account.
4. Next, it will set the role "Storage Blob Data Contributor" for the signed-in user.
5. It will then create a storage container.
6. Finally, you will be asked whether you want to upload a file or a directory. Enter 'f' for file or 'd' for directory, and then provide the   source path for the file or directory.

Requirements:
Azure CLI
Bash shell (for running this script)
Necessary permissions to create resources in Azure

Troubleshooting:
If you encounter any issues while running this script, make sure that:
Your Azure CLI is up to date.
You are logged in to the correct Azure account.
You have the necessary permissions to create and manage resources in Azure.
The names you are using for the resource group and storage account are unique and meet Azure's naming requirements.
