#!/bin/bash
#Бекап рабочего сервера (слейва)
#на слейве, создаём файл бекапа
mysqldump -u root -pUser1589$ --all-databases --events --routines --master-data=1 > /tmp/"backupDB-"`date +"%Y-%m-%d"`.sql


#НЕОБЯЗАТЕЛЬНО
#копируем бекап cо слейва 10.0.0.2 на новый мастер 10.0.0.3,
#требуется знать пользователя и адрес нового мастера
#ключ -r копирует папку целиком 
#вводим пароль пользователя adminroot
#scp -r /tmp/backupDB-*.sql adminroot@10.0.0.3:/tmp/


#на слейве изменить IP-адрес мастера (для пользователя abrepl)
#указать binlog.000000, MASTER_LOG_POS нового мастера
#ключ -e "TEXT" означатет выполнить команды в консоли mysql и выйти
sudo mysql -u root --password=User1589$ -e "STOP SLAVE; CHANGE MASTER TO MASTER_HOST='10.0.0.3', MASTER_USER='abrepl', MASTER_PASSWORD='User1589Rep$', MASTER_LOG_FILE='binlog.000005', MASTER_LOG_POS=706, GET_MASTER_PUBLIC_KEY = 1; START SLAVE; SHOW SLAVE STATUS\G"
