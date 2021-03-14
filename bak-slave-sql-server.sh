#!/bin/bash
#1)
#cd /tmp
#yum -y install wget
#wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
#rpm -ivh epel-release-latest-8.noarch.rpm
#yum -y install sshpass

#Предварительно на на сервере бекапов 10.0.0.3 создать пользователя
#useradd -c "Backup User MySQL" -b /tmp/ bkpuser && echo bkpuser:bKpassword$ | chpasswd

#2)
#Снять бекап cо СЛЕЙВА 10.0.0.2 и отправить на сервер бекапов 10.0.0.3 и мастер
sudo mysqldump -u root --password=User1589$ --all-databases --events --routines --master-data=1 > /tmp/backupDB.sql && sshpass -p bKpassword$ scp /tmp/backupDB.sql bkpuser@10.0.0.3:/tmp/
sudo mysqldump -u root --password=User1589$ --all-databases --events --routines --master-data=1 > /tmp/backupDB.sql && sshpass -p bKpassword$ scp /tmp/backupDB.sql bkpuser@10.0.0.1:/tmp/

#3)
#на новом сервере, c указываем позицию бинлога
#mysqlbinlog --start-position=526017 binlog.000002 | sudo mysql -u root -pUser1589$ < /tmp/backupDB.sql
