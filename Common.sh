echo "To find if the logged in user root or not"
var user
user = $(id -u)
if [ $user -ne 0 ]; then
echo "Logged in user is not root user."
exit 1
fi

echo " To check whethre the last command ran successfully or not"

StatusCheck () {

if [ $1 -eq 0 ]; then
echo -e "/e[32 Last command ran successfully. /e[0"
else
echo -e "/e[30 Last command did not run successfully. /e[0"
exit 1
fi

}

APPREQ ()
{
 echo " To verify whether Roboshop user already exists or not"

 id roboshop &>>${LOG_FILE}

 if [ $? -ne 0 ]; then
 echo " Logged in user is not roboshop, need to add roboshop user. "
 useradd roboshop
 StatusCheck $?

 echo " Once roboshop user is added, need to download files for specific ${Component} "

 curl -s -L -o /tmp/${Component}.zip "https://github.com/roboshop-devops-project/${Component}/archive/main.zip" &>>${LOG_FILE}
  

  if [ $(Component) -eq frontend ]; then
    echo " Stop NGINX service if already running. "
    systemctl stop ${Component}.service &>>${LOG_FILE}
    StatusCheck $?

    echo " Change current directory. "
    cd /usr/share/nginx/html &>>${LOG_FILE}
    StatusCheck $?

    echo " Delete older files if any. "
    rm -rf * &>>${LOG_FILE}
    StatusCheck $?

    echo " Unzip downloaded file in current directory. "
    unzip /tmp/${Component}.zip &>>${LOG_FILE}
    StatusCheck $?

    echo " Remove/Rename main folder. "
    mv ${Component}-main/static/* . &>>${LOG_FILE}
    StatusCheck $?

    echo " Remove/rename configuration file. "
    mv ${Component}-main/localhost.conf /etc/nginx/default.d/roboshop.conf &>>${LOG_FILE}
    StatusCheck $?

    echo " Start the service. "
    systemctl start nginx &>>${LOG_FILE}
    StatusCheck $?

  else
    echo " Stop service if already running. "
    systemctl stop ${Component}.service &>>${LOG_FILE}
    StatusCheck $?

    echo " Remove files from Home folder before unzipping new files. "
    cd /home/roboshop/  &>>${LOG_FILE}
    StatusCheck $?
    rm -rf ${Component} &??${LOG_FILE}
    StatusCheck $?

    unzip /tmp/${Component}.zip &>>${LOG_FILE}
    StatusCheck $?

    mv ${Component}-main ${Component}

 fi

}

System_Setup() {

  if [ $(Component) -eq frontend ]; then
   
  else
   
  fi

}

