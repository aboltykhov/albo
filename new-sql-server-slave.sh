#!/bin/bash
#Восстановление СЛЕЙВА
#1)
#на рабочем сервере, подготовка, чтобы копировать бекап без ввода пароля adminroot,
#требуется установка утилиты sshpass, утилита не входит в комплект, поэтому добавим дополнительный пакет
cd /tmp
#yum -y install wget
#wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
#rpm -ivh epel-release-latest-8.noarch.rpm
#yum -y install sshpass

#2)
#на новом слеве устанавливаем mysql-server
cd /tmp
yum update
rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el8-1.noarch.rpm
yum -y install mysql-server && systemctl enable mysqld && systemctl start mysqld && systemctl status mysqld

#настраиваем mysql-server, создаем пароль для root, например - User1589$
sudo mysql_secure_installation


#3)
#копируем бекап c рабочего сервера 10.0.0.1 на новый сервер 10.0.0.3
#требуется знать пользователя и адрес нового сервера
#ключ -r копирует папку целиком 
#вводим пароль пользователя adminroot
scp -r adminroot@10.0.0.1:/tmp/backupDB-*.sql /tmp/
#sshpass -p Candyshop919 scp -r adminroot@10.0.0.1:/tmp/backupDB-*.sql /tmp/

#на новом слеве разворачиваем бекап
sudo mysql -u root --password=User1589$ < /tmp/backupDB-*.sql


#4)
#на новом слеве настраиваем репликацию 
#сделаем копию и отредактируем файл конфигра
cp /etc/my.cnf.d/mysql-server.cnf /etc/my.cnf.d/mysql-server.cnf.bak
rm -rf /etc/my.cnf.d/mysql-server.cnf
#Добавить в конфиг строки, например ip нового слейва
cat <<EOF > /etc/my.cnf.d/mysql-server.cnf
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
log-error=/var/log/mysql/mysqld.log
pid-file=/run/mysqld/mysqld.pid
bind-address=10.0.0.2
server-id=2
EOF

#Перезапустить службу
systemctl restart mysqld && systemctl status mysqld


#5)
#на новом слейве настраиваем репликацию
#на слейве рекомендуется включить read_only
#включить read_only для слейва, иначе на слейве приложения тоже
#смогут вносить изменения, которые не будут сохраняться на мастере
#ключ -e "TEXT" означатет выполнить команды в консоли mysql и выйти
sudo mysql -u root --password=User1589$ -e "STOP SLAVE; CHANGE MASTER TO MASTER_HOST='10.0.0.1', MASTER_USER='abrepl', MASTER_PASSWORD='User1589Rep$', MASTER_LOG_FILE='binlog.000006', MASTER_LOG_POS=2167, GET_MASTER_PUBLIC_KEY = 1; START SLAVE; FLUSH TABLES WITH READ LOCK; SET GLOBAL read_only = ON; UNLOCK TABLES; SHOW SLAVE STATUS\G"
