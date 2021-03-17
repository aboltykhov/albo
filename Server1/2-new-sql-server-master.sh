#!/bin/bash
#Предварительно скрипт проверяет возможность своей работы от пользователя
if [[ $UID -ne 0 ]]; then
echo "Скрипт требуется запустить в привилегированном режиме sudo или от пользователя root"
exit 1; fi

#1)
#НЕОБЯЗАТЕЛЬНО
#на рабочем сервере, подготовка, чтобы копировать бекап без ввода пароля adminroot,
#требуется установка утилиты sshpass, утилита не входит в комплект, поэтому добавим дополнительный пакет
#cd /tmp
yum -y install wget
cd /tmp/
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
rpm -ivh epel-release-latest-8.noarch.rpm
yum -y install sshpass
rm -rf /tmp/epel-release-latest-8.noarch.rpm

#2)
#на новом МАСТЕРЕ устанавливаем mysql-server
rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el8-1.noarch.rpm
yum update && yum upgrade
yum -y install mysql-server && systemctl enable mysqld && systemctl start mysqld

#настраиваем mysql-server, создаем пароль для root, например - User1589$
sudo mysql_secure_installation

#3)
#на МАСТЕРЕ настраиваем репликацию 
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
sudo systemctl restart mysqld  && systemctl status mysqld

#4)
#На МАСТЕРЕ настраиваем репликацию
#ПРИ НЕОБХОДИМОСТИ меняет IP-адрес для слейва
#ключ mysql -e "TEXT" означатет выполнить команду в терминале и выйти
#удобнее импортировать из файла *.sql
sudo mysql -u root --password=User1589$ < /tmp/albo/SQL/replication.sql

#Создать пользователя root@10.0.0.2 для переноса бекапов в каталог /tmp/ 
sudo mysql -u root --password=User1589$ < /tmp/albo/SQL/bkp-user.sql

#Создать БД, пользователя wpuser для управления БД CMS WordPress
sudo mysql -u root --password=User1589$ < /tmp/albo/SQL/wp-db-user.sql

#Создать таблицу от имени пользователя wpuser, для проверки
sudo mysql -u wpuser --password=WP1password$ < /tmp/albo/SQL/wp-albo.sql

#5)
#Создать пользователя для копирования бекапов
useradd -c "Backup User MySQL" -b /tmp/ bkpuser && echo bkpuser:bKpassword$ | chpasswd

#Следующий скрипт графана, после графаны - прометей
cd /tmp/albo/Server1
./3-grafana-setup.sh
#################################################################	
#ПРИМЕРЫ
#Grant user permissions to all tables in my_database from localhost --
#GRANT ALL ON my_database.* TO 'user'@'localhost';

#Grant user permissions to my_table in my_database from localhost --
#GRANT ALL ON my_database.my_table TO 'user'@'localhost';

#Grant user permissions to all tables and databases from all hosts --
#GRANT ALL ON *.* TO 'user'@'*';

#FLUSH PRIVILEGES;
#################################################################
#Удалить пользователя
#SELECT user,host FROM mysql.user;
#SHOW GRANTS FOR 'wpuser'@'localhost';
#REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'wpuser'@'localhost';
#DROP USER 'wpuser'@'localhost';
#SELECT user,host FROM mysql.user;
#################################################################
