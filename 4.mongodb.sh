#!/bin/bash

user=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
W="\e[0m"

if [ $user -ne 0 ]; then
    echo -e " $R Error : user should have root privileges $W"
    exit 1
fi

logs_folder="/var/log/shell-roboshop"
script_name=$(echo $0 | cut -d "." -f2) # removing '4', '.sh' parts from the filename 4.mongodb.sh 
log_file="$logs_folder/$script_name.log"

mkdir -p $logs_folder  
echo "script execution started at : $(date)" | tee -a $log_file

check() 
{
    if [ $1 -ne 0 ]; then

        echo -e " $R $2 is not yet installed ! $W" | tee -a $log_file

        echo -e " $Y adding $2 repo ... $W" | tee -a $log_file
        cp 3.mongo.repo /etc/yum.repos.d/mongodb.repo
        validate $? "Adding $M repo"

        echo -e " $Y Installing $2 ... $W" | tee -a $log_file
        dnf install mongodb-org -y &>> $log_file
        validate $? "Installing $M"

        echo -e " $Y enabling $2 ... $W" | tee -a $log_file
        systemctl enable mongod &>> $log_file
        validate $? "Enabling $M"
    
        echo -e " $Y starting $2 ... $W" | tee -a $log_file
        systemctl start mongod &>> $log_file
        validate $? "Starting $M"

    else
        echo -e " $G $2 is already installed ! $W" | tee -a $log_file
    fi
}

validate() 
{
    if [ $1 -ne 0 ]; then
        echo -e " $2 $R is Failed !  $W" | tee -a $log_file
        exit 1
    else
        echo -e " $2 $G  is success ! $W " | tee -a $log_file
    fi
}

M=mongodb
dnf list installed $M &>> $log_file
check $? $M
    
    
