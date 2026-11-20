#!/bin/bash

source ./common.sh

check_root


cp mongo.repo /etc/yum.repos.d/mongo.repo 
validate $? "Adding mongo repo"

dnf install mongodb-org -y &>>$logs_file
validate $? "Install mongodb"

systemctl enable mongod &>>$logs_file
systemctl start mongod &>>$logs_file
validate $? "enable and start mongodb"

sed -i 's/^[[:space:]]*bindIp:.*/  bindIp: 0.0.0.0/' /etc/mongod.conf
validate $? "updating remote connections to mongodb"

systemctl restart mongod 
validate $? "restarting mongodb"

total_time
