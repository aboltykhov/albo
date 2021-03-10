#!/bin/bash
#1)
#cd /tmp
#yum -y install wget
#wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
#rpm -ivh epel-release-latest-8.noarch.rpm
#yum -y install sshpass


#2)
#Снять бекап cо СЛЕЙВА 10.0.0.2 и отправить на сервер бекапов 10.0.0.3
sudo mysqldump -u root --password=User1589$ --all-databases --events --routines --master-data=1 > /tmp/"backupDB-"`date +"%Y-%m-%d"`.sql && sshpass -p bKpassword$ scp /tmp/backupDB-*.sql bkpuser01@10.0.0.3:/tmp/bkps/
