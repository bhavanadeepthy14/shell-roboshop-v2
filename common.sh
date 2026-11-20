#!/bin/bash
user_id=$(id -u)
logs_folder="/var/log/shell-practice"
logs_file="${logs_folder}/${0}.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
check_root() {
if [ $user_id -ne 0 ]; then
  echo "please run this script with sudo access.."
  exit 1
fi
}
timestamp()
{
    date +"%F %T"
}
mkdir -p $logs_folder
 echo -e "$(timestamp) [INFO] ===== script started execution =====" | tee -a $logs_file 
 
 validate () 
{
    if [ $1 -ne 0 ]; then
        echo -e "$(timestamp) [ERROR] {$2}..${R}failed${N}" | tee -a $logs_file
        exit 1
    else
        echo -e "$(timestamp) [INFO] {$2}..${G}success${N}" | tee -a $logs_file
    fi
}
nodejs_setup() 
{
    dnf module disable nodejs -y &>>$logs_file
    dnf module enable nodejs:24 -y &>>$logs_file
    dnf install nodejs -y &>>$logs_file
    validate $? "installing nodejs"
    npm install &>>$logs_file
    validate $? "installing nodejs dependencies" 
}
#java_setup()
#{
#dnf module enable maven:3.9 -y &>>$logs_file
#dnf install maven java-25-openjdk-devel -y &>>$logs_file
#validate $? "installing maven and java"
#alternatives --set java /usr/lib/jvm/java-25-openjdk/bin/java 
#validate $? "setting java 25 as default java version"
#mvn clean package &>>$logs_file
#validate $? "installing java dependencies" 
#mv target/shipping.jar shipping.jar
#validate $? "moving shipping jar file"
#}
#echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f /usr/bin/java)))" > /etc/profile.d/java.sh
#source /etc/profile.d/java.sh
#echo $JAVA_HOME
#validate $? "setting JAVA_HOME for maven" 
#}
 app_setup() 
{
id roboshop &>>$logs_file
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$logs_file
validate $? "creating roboshop system user"
else
    echo -e "$(timestamp) [INFO] system user roboshop already exists....${Y}skipping${N}" 
fi
 
rm -rf /app 
validate $? "removing old code"
mkdir -p /app
validate $? "creating app directory"
curl -L -o /tmp/app_name.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/catalogue-v4.zip &>>$logs_file
validate $? "downloading app_name"
cd /app
unzip /tmp/app_name.zip &>>$logs_file
validate $? "unzipping app_name"  
}
systemd_setup() 
{
sed -i "s/DOMAIN_NAME/$domain_name/g" "$scripts_dir/$app_name.service"
cp "$scripts_dir/$app_name.service" /etc/systemd/system/$app_name.service
systemctl daemon-reload &>>$logs_file
systemctl enable $app_name &>>$logs_file
systemctl start $app_name &>>$logs_file
}
restart(){
    systemctl restart app_name
    validate $? "restarting app_name"
}
total_time() 
{
    echo "$(timestamp) [INFO] script completed in $SECONDS seconds" | tee -a $logs_file
    echo "$(timestamp) [INFO] ===== script completed execution =====" | tee -a $logs_file}
}
