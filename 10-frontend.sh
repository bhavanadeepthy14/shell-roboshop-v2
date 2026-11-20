#!/bin/bash
source ./common.sh

check_root

dnf module disable nginx -y &>>$logs_file
dnf module enable nginx:1.26 -y &>>$logs_file
dnf install nginx -y &>>$logs_file
validate $? "installing nginx"

systemctl enable nginx &>>$logs_file
systemctl start nginx &>>$logs_file
validate $? "enable and start nginx"

rm -rf /usr/share/nginx/html/* &>>$logs_file
validate $? "removing default nginx content"

curl -L -o /tmp/frontend.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/frontend-v4.zip &>>$logs_file
cd /usr/share/nginx/html &>>$logs_file
unzip /tmp/frontend.zip &>>$logs_file
validate $? "downloading and unzipping frontend code"

sed -i "s/DOMAIN_NAME/$domain_name/g" "$scripts_dir/roboshop.conf"
cp "$scripts_dir/roboshop.conf" /etc/nginx/default.d/roboshop.conf
validate $? "copying roboshop configuration file"

nginx -t &>>$logs_file
validate $? "Nginx configuration"

systemctl restart nginx &>>$logs_file
validate $? "restarting nginx"

total_time

