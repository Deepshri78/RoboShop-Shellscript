echo -e "\e[32m This script will prepare every node before installation.\e[0m"

echo -e "\e[32m Disabling enhanced security \e[0m"
cd /etc/selinux
sed -i 's/enforcing/disabled/g' /etc/selinux/config 

setenforce 0 

echo -e "\e[32m Installing Git \e[0m"
cd ~
yum install git -y 

sleep 15

git clone https://github.com/Deepshri78/RoboShop-Shellscript.git

