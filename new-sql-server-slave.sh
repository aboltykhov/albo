#!/bin/bash
#1)
#на рабочем сервере, подготовка, чтобы копировать бекап без ввода пароля adminroot,
#требуется установка утилиты sshpass, утилита не входит в комплект, добавим доп. пакет
cd /tmp
yum -y install wget
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
rpm -ivh epel-release-latest-8.noarch.rpm
yum -y install sshpass


#2)
#на SLAVE устанавливаем mysql-server
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
sudo mysql -u root --password=User1589$ < /tmp/dz_itog/replication-slave.sql


#4)
#Создать пользователя на 10.0.0.3 для передачи бекапов
#rm -rf /tmp/bkps
#userdel -rf bkpuser01
#useradd --no-create-home --shell /bin/bash bkpuser01 && echo bkpuser01:bKpassword$ | chpasswd
#mkdir -p /tmp/bkps && chown -R bkpuser01:bkpuser01 /tmp/bkps/


#5)
#Снять первый бекап cо СЛЕЙВА 10.0.0.2 и смразу отправить на сервер бекапов 10.0.0.3
#Без указания даты
mysqldump -u root --password=User1589$ --all-databases --events --routines --master-data=1 > /home/adminroot/backupDB.sql && sshpass -p bKpassword$ scp /home/adminroot/backupDB.sql  bkpuser@10.0.0.3:/tmp/

#С указанием даты
#mysqldump -u root --password=User1589$ --all-databases --events --routines --master-data=1 > /home/adminroot/"backupDB-"`date +"%Y-%m-%d"`.sql && sshpass -p bKpassword$ scp /home/adminroot/backupDB.sql bkpuser@10.0.0.3:/tmp/

#Добавить в планировщик crontab регулярый бекап
#Запускать скрипт каждую минуту и отправлять на другой сервер каждую вторую минуту
sudo echo -e '01 * * * * /tmp/dz_itog/bak-slave-sql-server.sh; 02 * * * * mysql -h 10.0.0.3 -u root --password=User1589$ < /tmp/backupDB.sql'| sudo crontab -

#6)
#Следующий скрипт node-exporter для снияти метрик сервера
cd /tmp/dz_itog
./node-exporter-client-setup.sh
