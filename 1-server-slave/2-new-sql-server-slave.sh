#!/bin/bash
#Предварительно скрипт проверяет возможность своей работы от пользователя
if [[ $UID -ne 0 ]]; then
echo "Скрипт требуется запустить в привилегированном режиме sudo или от пользователя root"
exit 1; fi

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
rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el8-1.noarch.rpm
yum update
yum -y install mysql-server && systemctl enable mysqld && systemctl start mysqld && systemctl status mysqld

#настраиваем mysql-server, создаем пароль для root, например - User1589$
mysql_secure_installation

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
mysql -u root --password=User1589$ < /tmp/albo/sql/replication-slave.sql

#4)
#Создать пользователя для передачи бекапов
#rm -rf /tmp/bkpuser
userdel -rf bkpuser
useradd -c "Backup User MySQL" -m --shell /bin/bash bkpuser && echo bkpuser:bKpassword$ | chpasswd

#5)
#Проверка! Снять первый бекап cо СЛЕЙВА и отправить на сервер бекапов 10.0.0.3
mysqldump -u root --password=User1589$ --all-databases --events --routines --master-data=1 > /home/bkpuser/backupDB.sql && sshpass -p bKpassword$ scp /home/bkpuser/backupDB.sql bkpuser@10.0.0.3:/home/bkpuser/

#Добавить задания в планировщик crontab
#Запускать скрипт каждую минуту создавая бекап и отправлять бекап на другой сервер каждую вторую минуту
crontab < /tmp/albo/crontab.txt

#6)
#Следующий скрипт node-exporter для снияти метрик сервера
cd /tmp/albo/1-server-slave
./3-node-exporter-client-setup.sh
