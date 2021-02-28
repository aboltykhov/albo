#!/bin/bash
#Бекап рабочего сервера (мастера)
#1)
#на рабочем сервере, подготовка, чтобы копировать бекап без ввода пароля adminroot,
#требуется установка утилиты sshpass, утилита не входит в комплект, поэтому добавим дополнительный пакет
cd /tmp
yum -y install wget
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
rpm -ivh epel-release-latest-8.noarch.rpm
yum -y install sshpass


#2)
#на рабочем сервере, создание файла бекапа
mysqldump -u root --password=User1589$ --all-databases --events --routines --master-data=1 > /tmp/"backupDB-"`date +"%Y-%m-%d"`.sql


#3)
#копируем бекап c рабочего сервера 10.0.0.1 на новый сервер 10.0.0.3,
#требуется знать пользователя и адрес нового сервера
#ключ scp -r копирует папку целиком 
#вводим пароль пользователя adminroot
#scp -r /tmp/backupDB-*.sql adminroot@10.0.0.3:/tmp/
#sshpass -p Candyshop919 scp -r /tmp/backupDB-*.sql adminroot@10.0.0.3:/tmp/


#4)
#на мастере создаем пользователя@адрес нового слейва и пароль
#даем права пользователю слейва (*.* на все таблицы) на репликацию
#ключ -e "TEXT" означатет выполнить команды в консоли mysql и выйти
sudo mysql -u root --password=User1589$ -e "CREATE USER abrepl@10.0.0.3 IDENTIFIED WITH caching_sha2_password BY 'User1589Rep$'; GRANT REPLICATION SLAVE ON *.* TO abrepl@10.0.0.3"

#ключ -e "TEXT" означатет выполнить команды в консоли mysql и выйти
#проверяем и запоминаем из таблицы File: binlog.000000 и Position 000
sudo mysql -u root --password=User1589$ -e "SELECT User, Host FROM mysql.user; SHOW MASTER STATUS\G"


