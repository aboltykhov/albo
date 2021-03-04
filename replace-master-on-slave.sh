#!/bin/bash
#на СЛЕЙВЕ меняем мастера (для пользователя abrepl)

#меняем IP-адресс мастера
#указываем binlog.000000 и MASTER_LOG_POS нового мастера
sudo mysql -u root --password=User1589$ -e "STOP SLAVE; CHANGE MASTER TO MASTER_HOST='10.0.0.3', MASTER_USER='abrepl', MASTER_PASSWORD='User1589Rep$', MASTER_LOG_FILE='binlog.000002', MASTER_LOG_POS=1046001, GET_MASTER_PUBLIC_KEY = 1; START SLAVE; SHOW SLAVE STATUS\G"

#И СДЕЛАТЬ РИД-ОНЛИ, ЧЕРЕЗ ФАЙЛ КОНФИГА
