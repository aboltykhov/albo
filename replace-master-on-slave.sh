#!/bin/bash
#меняем мастера для репликации (для пользователя abrepl)
#указываем binlog.000000 и MASTER_LOG_POS=000000 нового мастера
sudo mysql -u root --password=User1589$ < /tmp/albo/SQL/change-sql-binlog.sql
