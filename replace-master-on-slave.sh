#!/bin/bash
#Предварительно скрипт проверяет возможность своей работы от пользователя
if [[ $UID -ne 0 ]]; then
echo "Скрипт требуется запустить в привилегированном режиме sudo или от пользователя root"
exit 1; fi

#Меняем мастера для репликации
#Указываем binlog.000000 и MASTER_LOG_POS=000000 нового мастера в slq/change-sql-binlog.sql
mysql -u root --password=User1589$ < /tmp/albo/sql/change-sql-binlog.sql

