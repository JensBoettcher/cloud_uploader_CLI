#!/bin/bash



#ANCHOR - functions section

#NOTE - function to check the Azure resource-group-name policies
check_resource_group_name() {
    local name="$1"
    #check name is empty
    if [ -z "$name" ]; then
        echo "Please enter a name."
        return 1
    fi
    #check the name for valid signs
    if [[ "$name" =~ [^a-zA-Z0-9\._-] ]]; then
        echo "Only letter, numbers, points, underscore and hyphen are valid signs."
        return 1
    fi
    #check the name length
    if [ ${#name} -gt 90 ]; then
        echo "The maximum name length is 90 characters."
        return 1
    fi
    return 0
}

#NOTE - function to check the Azure vm-name policies
check_vm_name() {
    local vm_name="$1"
    #check name is empty
    if [ -z "$vm_name" ]; then
        echo "Please enter a name. With minimum 1 character"
        return 1
    fi
    #check the name for valid signs
    if [[ "$vm_name" =~ [^a-zA-Z0-9\._-] ]]; then
        echo "Only letter, numbers, points, underscore and hyphen are valid signs."
        return 1
    fi
    #check the name length
    if [ ${#vm_name} -gt 64 ]; then
        echo "The maximal name length is 64 characters."
        return 1
    fi
    return 0
}

#NOTE - function for checking the name of the admin-user
check_user_name() {
    local user_name="$1"
    #check name is empty
    if [ -z "$user_name" ]; then
        echo "Please enter a name with minimum 1 character"
        return 1
    fi
    #check valid characters
    if ! [[ "$user_name" =~ ^[a-z0-9]+$ ]]; then
        echo "Your user name is not valid. No upper case character, special characters or start with $ or - allowed."
        return 1
    fi
    return 0
}




#ANCHOR - login into the Azure account
az login



#ANCHOR - read the users resource-group-name input
while true; do
    read -p "Please enter a resource-group name: " resource_group_name
    #check the name of the resource-group
    if check_resource_group_name "$resource_group_name"; then
        break
    fi
done
echo "The name of your resource-group is: $resource_group_name"

#ANCHOR - read the users vm-name input
 while true; do
    read -p "Please enter a name for your vm: " vm_name
    if check_vm_name "$vm_name"; then
        break
    fi
done
echo "The name of your vm will be: $vm_name"

#ANCHOR - read the valid user name
while true; do
    read -p "Please enter a name for the admin user-account: " admin_user
    if check_user_name "$admin_user"; then
        break
    fi
done
echo "The admin-user-name is: $admin_user"
#NOTE - NSG variable
nsg_name=$vm_name"NSG"

#ANCHOR - create a resource group
az group create \
    --name $resource_group_name \
    --location germanywestcentral

#ANCHOR - create a ubuntu 22.04 vm
az vm create \
    --resource-group $resource_group_name \
    --name $vm_name \
    --image Ubuntu2204 \
    --generate-ssh-keys \
    --public-ip-sku Standard \
    --admin-username $admin_user \
    --verbose

#ANCHOR - create nsg rule to open ssh port 22
az network nsg rule create \
    --resource-group $resource_group_name \
    --nsg-name $nsg_name \
    --name AllowSSH \
    --protocol Tcp \
    --direction Inbound \
    --priority 100 \
    --source-address-prefix "*" \
    --source-port-range "*" \
    --destination-address-prefix "*" \
    --destination-port-ranges 22 \
    --access Allow

#ANCHOR - create nsg rule to open HTTP port 22
az network nsg rule create \
    --resource-group $resource_group_name \
    --nsg-name $nsg_name \
    --name AllowHTTP \
    --protocol Tcp \
    --direction Inbound \
    --priority 150 \
    --source-address-prefix "*" \
    --source-port-range "*" \
    --destination-address-prefix "*" \
    --destination-port-ranges 80 \
    --access Allow

#ANCHOR - wait for vm deploy
while [ "$(az vm show \
    --resource-group $resource_group_name \
    --name $vm_name \
    --query "provisioningState" \
    --output \
    tsv)" != "Succeeded" ];
do
    sleep 10
done


#ANCHOR - show public ip
public_ip=$(az vm show \
    --resource-group $resource_group_name \
    --name $vm_name \
    --show-details \
    --query "publicIps" \
    --output tsv)


#ANCHOR - fingerprint query automation
#NOTE - It is not recommended for safety reasons
ssh -o StrictHostKeyChecking=accept-new -i /home/ifrit1983/.ssh/id_rsa $admin_user@$public_ip << EOF
sudo apt update
sudo apt upgrade -y
sudo apt install -y apache2 
sudo apt install mysql-server 
sudo apt install php libapache2-mod-php php-mysql
sudo systemctl restart apache2
EOF

#ANCHOR - connect with the vm
ssh -i /home/ifrit1983/.ssh/id_rsa $admin_user@$public_ip
