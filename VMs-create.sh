echo "Creating VMs on Azure using shell script"

declare -a vmimage

vmimage = (catalogue user cart payment shipping dispatch mongodb mysql redis rabbitmq)


for component in vmimage ; do
az vm create --resource-group Roboshop-Using-Shell --name $component --image OpenLogic:CentOS-LVM:8-lvm-gen2:8.5.2022101401 --vnet-name azure-training-2023-vnet --subnet default  --admin-username centos --admin-password DevOps654321 --public-ip-sku "" --size Standard_B1s --nsg NSG_Roboshop_Using-Shell
az vm auto-shutdown --resource-group Roboshell-Using-Shell -name  $component --time 1830  
done