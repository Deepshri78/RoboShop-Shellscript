echo "To find if the logged in user root or not"
declare loggedinuser
loggedinuser=$(id -u)
if [ $loggedinuser -ne 0 ]; then
echo "Logged in user is not root user."
exit 1
fi

#echo " To check whether the last command ran successfully or not"

StatusCheck () {

if [ $1 -eq 0 ]; then
echo -e "\e[32m Last command ran successfully. \e[0m"
else
echo -e "\e[31m Last command did not run successfully. \e[0m"
exit 1
fi

}

APPREQ () {

 echo -e "\e[32m  To verify whether Roboshop user already exists or not"

 id roboshop &>>${LOG_FILE}

 if [ $? -ne 0 ]; then
 echo -e "\e[32m  Logged in user is not roboshop, need to add roboshop user. \e[0m"
 useradd roboshop &>>${LOG_FILE}
 StatusCheck $?
 fi

 echo -e "\e[32m  Once roboshop user is added, need to download files for specific ${COMPONENT} \e[0m"

 curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>>${LOG_FILE}
  

  if [ ${COMPONENT} == frontend ]; then
    echo -e "\e[32m  Stop NGINX service if already running. \e[0m"
    yum install nginx -y
    #systemctl stop ${COMPONENT}.service &>>${LOG_FILE}
    StatusCheck $?

    echo -e "\e[32m  Change current directory. \e[0m"
    cd /usr/share/nginx/html &>>${LOG_FILE}
    StatusCheck $?

    echo -e "\e[32m  Delete older files if any. \e[0m"
    rm -rf * &>>${LOG_FILE}
    StatusCheck $?

    echo -e "\e[32m  Unzip downloaded file in current directory. \e[0m"
    unzip /tmp/${COMPONENT}.zip &>>${LOG_FILE}
    StatusCheck $?

    echo -e "\e[32m  Remove/Rename main folder. \e[0m"
    mv ${COMPONENT}-main/static/* . &>>${LOG_FILE}
    StatusCheck $?

    echo -e "\e[32m  Remove/rename configuration file. \e[0m"
    mv ${COMPONENT}-main/localhost.conf /etc/nginx/default.d/roboshop.conf &>>${LOG_FILE}
    StatusCheck $?

    echo -e "\e[32m  Start the service. \e[0m"
    systemctl start nginx &>>${LOG_FILE}
    StatusCheck $?

  else

    echo -e "\e[32m  Stop service if already running. \e[0m"
    systemctl stop ${COMPONENT}.service &>>${LOG_FILE}
    

    echo -e "\e[32m  Remove files from Home folder before unzipping new files. \e[0m"
    cd /home/roboshop/  &>>${LOG_FILE}
    StatusCheck $?
    rm -rf ${COMPONENT} &??${LOG_FILE}
    

    echo -e "\e[32m  Unzip files \e[0m"
    unzip /tmp/${COMPONENT}.zip &>>${LOG_FILE}
    StatusCheck $?

    echo -e "\e[32m  Renaming -main file \e[0m"
    mv ${COMPONENT}-main ${COMPONENT} &>>${LOG_FILE}
    StatusCheck $?

    echo -e "\e[32m  Changing the current directory \e[0m"
    cd /home/roboshop/${COMPONENT} &>>${LOG_FILE}
    StatusCheck $?


 fi
 
 }

 Starting_Service() {
    if [ ${COMPONENT} == catalogue ]; then
    sed -i 's/MONGO_DB/10.0.0.12/g' /home/roboshop/${COMPONENT}/systemd.service
    fi

    if [ ${COMPONENT} == cart ]; then
    sed -i 's/CATALOGUE_ENDPOINT/10.0.0.6/g' /home/roboshop/${COMPONENT}/systemd.service
    sed -i 's/REDIS_ENDPOINT/10.0.0.14/g' /home/roboshop/${COMPONENT}/systemd.service
    fi

    if [ ${COMPONENT} == user ]; then
    sed -i 's/MONGO_DB/10.0.0.12/g' /home/roboshop/${COMPONENT}/systemd.service
    sed -i 's/REDIS_ENDPOINT/10.0.0.14/g' /home/roboshop/${COMPONENT}/systemd.service
    fi

    if [ ${COMPONENT} == payment ]; then
    sed -i 's/CARTHOST/10.0.0.7/g' /home/roboshop/${COMPONENT}/systemd.service
    sed -i 's/USERHOST/10.0.0.8/g' /home/roboshop/${COMPONENT}/systemd.service
    sed -i 's/AMQHOST/10.0.0.15/g' /home/roboshop/${COMPONENT}/systemd.service
    fi

    if [ ${COMPONENT} == shipping ]; then
    sed -i 's/CARTENDPOINT/10.0.0.7/g' /home/roboshop/${COMPONENT}/systemd.service
    sed -i 's/DBHOST/10.0.0.13/g' /home/roboshop/${COMPONENT}/systemd.service
    fi

    mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service &>>${LOG_FILE}
    
    systemctl daemon-reload &>>${LOG_FILE}
    StatusCheck $?

    systemctl enable ${COMPONENT}.service &>>${LOG_FILE}
    StatusCheck $?

    systemctl start ${COMPONENT}.service &>>${LOG_FILE}
    StatusCheck $?
 }

 System_Setup() {

  if [ ${COMPONENT} == catalogue ] || [ ${COMPONENT} == cart ] || [ ${COMPONENT} == user ]; then
   
    echo -e "\e[32m This is Catalogue/Cart/User. \e[0m"

    curl -sL https://rpm.nodesource.com/setup_lts.x  &>>${LOG_FILE}
    StatusCheck $?

    yum install nodejs -y &>>${LOG_FILE}
    StatusCheck $?

    APPREQ

    echo -e "\e[32m Appreq went well, now NPM install \e[0m"

    npm install  &>>${LOG_FILE}
    StatusCheck $?

    Starting_Service
   
  elif [ ${COMPONENT} == payment ]; then
    
    echo -e "\e[32m This is Payment. \e[0m"

    yum install python36 gcc python3-devel -y  &>>${LOG_FILE}
    StatusCheck $?


    APPREQ

    echo -e "\e[32m Appreq went well, now PIP3 install \e[0m"

    pip3 install -r requirements.txt  &>>${LOG_FILE}
    StatusCheck $?

    Starting_Service

    elif [ ${COMPONENT} == dispatch ]; then
    
    echo -e "\e[32m This is Dispatch. \e[0m"

    yum install golang -y  &>>${LOG_FILE}
    StatusCheck $?


    APPREQ

    echo -e "\e[32m Appreq went well, now build \e[0m"

    go mod init dispatch
    go get 
    go build  &>>${LOG_FILE}
    StatusCheck $?

    Starting_Service

    elif [ ${COMPONENT} == shipping ]; then
    
    echo -e "\e[32m This is Shipping. \e[0m"

    yum install maven -y  &>>${LOG_FILE}
    StatusCheck $?


    APPREQ

    echo -e "\e[32m Appreq went well, now clean package \e[0m"

    mvn clean package 
    mv target/shipping-1.0.jar shipping.jar  &>>${LOG_FILE}
    StatusCheck $?

    Starting_Service

    elif [ ${COMPONENT} == mongo ]; then
    
    echo -e "\e[32m This is MongoDB. \e[0m"

    curl -s -o /etc/yum.repos.d/mongodb.repo "https://raw.githubusercontent.com/roboshop-devops-project/mongodb/main/mongo.repo"
    yum install mongodb-org -y  &>>${LOG_FILE}
    StatusCheck $?

    echo -e "\e[32m Starting service \e[0m"
    systemctl enable mongod
    systemctl start mongod

    echo -e "\e[32m Changing the config file \e[0m"
    sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
    systemctl restart mongod

    curl -s -L -o /tmp/mongodb.zip "https://github.com/roboshop-devops-project/mongodb/archive/main.zip"
    cd /tmp
    unzip mongodb.zip
    cd mongodb-main
    mongo < catalogue.js
    mongo < users.js

    elif [ ${COMPONENT} == redis ]; then
    
    echo -e "\e[32m This is Redis. \e[0m"

    dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y
    dnf module enable redis:remi-6.2 -y
    dnf install redis -y  &>>${LOG_FILE}
    StatusCheck $?

    echo -e "\e[32m Changing the config file \e[0m"
    sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf
    sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf

    echo -e "\e[32m Starting service \e[0m"
    systemctl enable redis
    systemctl start redis


  fi

 }

