#!/bin/bash
#Отправить на сервер бекапов 10.0.0.3
mysql -h 10.0.0.3 -u root --password=User1589$ < /tmp/backupDB.sql

