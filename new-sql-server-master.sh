#!/bin/bash
#Восстановление МАСТЕРА
#1)
#НЕОБЯЗАТЕЛЬНО
#на рабочем сервере, подготовка, чтобы копировать бекап без ввода пароля adminroot,
#требуется установка утилиты sshpass, утилита не входит в комплект, поэтому добавим дополнительный пакет
#cd /tmp
#yum -y install wget
#wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
#rpm -ivh epel-release-latest-8.noarch.rpm
#yum -y install sshpass


#2)
#на новом МАСТЕРЕ устанавливаем mysql-server
cd /tmp
yum update
rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el8-1.noarch.rpm
yum -y install mysql-server && systemctl enable mysqld && systemctl start mysqld && systemctl status mysqld

#настраиваем mysql-server, создаем пароль для root, например - User1589$
sudo mysql_secure_installation


#3)
#на новом МАСТЕРЕ настраиваем репликацию 
#сделаем копию и отредактируем файл конфигра
cp /etc/my.cnf.d/mysql-server.cnf /etc/my.cnf.d/mysql-server.cnf.bak
rm -rf /etc/my.cnf.d/mysql-server.cnf
#Добавить строки, ip нового мастера
cat <<EOF > /etc/my.cnf.d/mysql-server.cnf
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
log-error=/var/log/mysql/mysqld.log
pid-file=/run/mysqld/mysqld.pid
bind-address=10.0.0.1
server-id=1
EOF

#Перезапустить службу
systemctl restart mysqld


#4)
#копируем бекап на новый МАСТЕР
#требуется знать пользователя и адрес сервера с бекапом
#ключ scp -r копирует папку целиком 
#вводим пароль пользователя adminroot
#scp -r adminroot@10.0.0.2:/tmp/backupDB-*.sql /tmp/
#sshpass -p Candyshop919 scp -r adminroot@10.0.0.1:/tmp/backupDB-*.sql /tmp/

#на новом МАСТЕРЕ разворачиваем бекап
#sudo mysql -u root --password=User1589$ < /tmp/backupDB-*.sql


#5)
#на новом МАСТЕРЕ настраиваем репликацию
#ПРИ НЕОБХОДИМОСТИ меняет IP-адрес для слейва
#ключ -e "TEXT" означатет выполнить команды в консоли mysql и выйти
sudo mysql -u root --password=User1589$ -e "CREATE USER abrepl@10.0.0.2 IDENTIFIED WITH caching_sha2_password BY 'User1589Rep$'; GRANT REPLICATION SLAVE ON *.* TO abrepl@10.0.0.2; SELECT User, Host FROM mysql.user; SHOW MASTER STATUS\G"
