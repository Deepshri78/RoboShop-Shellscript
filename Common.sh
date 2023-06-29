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
    #systemctl stop ${COMPONENT}.service &>>${LOG_FILE}
    StatusCheck $?

    echo -e "\e[32m  Remove files from Home folder before unzipping new files. \e[0m"
    cd /home/roboshop/  &>>${LOG_FILE}
    StatusCheck $?
    rm -rf ${COMPONENT} &??${LOG_FILE}
    StatusCheck $?

    unzip /tmp/${COMPONENT}.zip &>>${LOG_FILE}
    StatusCheck $?

    mv ${COMPONENT}-main ${COMPONENT} &>>${LOG_FILE}
    StatusCheck $?

    cd /home/roboshop/${COMPONENT} &>>${LOG_FILE}
    StatusCheck $?


 fi
 
 }

 Starting_Service() {
    if [ ${COMPONENT} == Catalogue ]; then
    sed -i 's/MONGO_DB/10.0.0.12/g' /home/roboshop/${COMPONENT}/Systemd.service
    fi

    mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service &>>${LOG_FILE}
    StatusCheck $?

    systemctl daemon-reload &>>${LOG_FILE}
    StatusCheck $?

    systemctl enable ${COMPONENT}.service &>>${LOG_FILE}
    StatusCheck $?

    systemctl start ${COMPONENT}.service &>>${LOG_FILE}
    StatusCheck $?
 }

 System_Setup() {

  if [ ${COMPONENT} == frontend ]; then
   
  echo "Hi"
   
  elif [ ${COMPONENT} == Catalogue ]; then
    
    echo -e "\e[32m This is Catalogue. \e[0m"

    curl -sL https://rpm.nodesource.com/setup_lts.x  &>>${LOG_FILE}
    StatusCheck $?

    yum install nodejs -y &>>${LOG_FILE}
    StatusCheck $?

    APPREQ

    npm install  &>>${LOG_FILE}
    StatusCheck $?

    Starting_Service

    


  fi

 }

