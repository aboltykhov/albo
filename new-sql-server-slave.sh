#!/bin/bash
#Восстановление СЛЕЙВА
#1)
#на рабочем сервере, подготовка, чтобы копировать бекап без ввода пароля adminroot,
#требуется установка утилиты sshpass, утилита не входит в комплект, поэтому добавим дополнительный пакет
cd /tmp
yum -y install wget
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
rpm -ivh epel-release-latest-8.noarch.rpm
yum -y install sshpass


#2)
#на новом слеве устанавливаем mysql-server
cd /tmp
yum update
rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el8-1.noarch.rpm
yum -y install mysql-server && systemctl enable mysqld && systemctl start mysqld && systemctl status mysqld

#настраиваем mysql-server, создаем пароль для root, например - User1589$
sudo mysql_secure_installation


#3)
#на SLAVE настраиваем репликацию 
#сделаем копию и отредактируем файл конфигра, добавив права только для чтения
#включаем read_only для слейва, иначе на слейве приложения тоже
#смогут вносить изменения, которые не будут сохраняться на мастере
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
read_only=ON
EOF

#Перезапустить службу
systemctl restart mysqld


#4)
#На SLAVE настраиваем репликацию
#ключ -e "TEXT" означатет выполнить команды в консоли mysql и выйти
sudo mysql -u root --password=User1589$ -e "CHANGE MASTER TO MASTER_HOST='10.0.0.1', MASTER_USER='abrepl', MASTER_PASSWORD='User1589Rep$', MASTER_LOG_FILE='binlog.000002', MASTER_LOG_POS=706, GET_MASTER_PUBLIC_KEY = 1; START SLAVE; SHOW SLAVE STATUS\G; show variables like '%read_only%';"


#5)
#Создать пользователя на 10.0.0.3 для передачи бекапов
#rm -rf /tmp/bkps
#userdel -rf bkpuser01
#useradd --no-create-home --shell /bin/bash bkpuser01 && echo bkpuser01:bKpassword$ | chpasswd
#mkdir -p /tmp/bkps && chown -R bkpuser01:bkpuser01 /tmp/bkps/


#6)
#Снять бекап cо СЛЕЙВА 10.0.0.2 и отправить на сервер бекапов 10.0.0.3
#Без указания даты
sudo mysqldump -u root --password=User1589$ --all-databases --events --routines --master-data=1 > /tmp/backupDB.sql && sshpass -p bKpassword$ scp /tmp/backupDB.sql bkpuser@10.0.0.3:/tmp/

#С указанием даты
#sudo mysqldump -u root --password=User1589$ --all-databases --events --routines --master-data=1 > /tmp/"backupDB-"`date +"%Y-%m-%d"`.sql && sshpass -p bKpassword$ scp /tmp/backupDB-*.sql bkpuser@10.0.0.3:/tmp/


#Добавить в планировщик cron регулярый бекап
#Запускать скрипт раз в день в 01:00
sudo echo -e '0 1 * * * /tmp/dz_itog/bak-slave-sql-server.sh; 0 2 * * * mysql -h 10.0.0.3 -u root --password=User1589$ < /tmp/backupDB.sql'| sudo crontab -


