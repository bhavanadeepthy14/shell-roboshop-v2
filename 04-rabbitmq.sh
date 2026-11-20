#!/bin/bash

source ./common.sh

check_root

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
validate $? "Adding rabbitmq repo"

dnf install erlang rabbitmq-server -y &>>$logs_file
validate $? "installing rabbitmq"

systemctl enable rabbitmq-server &>>$logs_file
systemctl start rabbitmq-server &>>$logs_file
validate $? "enable and start rabbitmq"

rabbitmqctl list_users  |  grep -qw "roboshop"
if [ $? -ne 0 ]; then
    rabbitmqctl add_user roboshop roboshop123 &>>$logs_file
    validate $? "setup rabbitmq user for roboshop"
else
    echo -e "$(timestamp) [INFO] roboshop user already exists....${Y}skipping${N}" 
fi
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$logs_file
validate $? "setup rabbitmq permissions for roboshop"

total_time

