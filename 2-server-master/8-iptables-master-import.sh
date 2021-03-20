#!/bin/bash
#Предварительно скрипт проверяет возможность своей работы от пользователя
if [[ $UID -ne 0 ]]; then
echo "Скрипт требуется запустить в привилегированном режиме sudo или от пользователя root"
exit 1; fi

#Устанавливаем службу управления доступом к портам
yum -y install iptables iptables-services

#Включаем службу в автозагрузку
systemctl enable iptables.service

#Импортируем коннфиг
iptables-restore < /tmp/albo/iptables-master

#Отключаем из автозагрузки фаервол
systemctl disable firewalld.service

#Сохраняем правила
service iptables save

####################################################################
#Перед тем как удалить все правила
#iptables -L -n -v --line-numbers
#iptables -P INPUT ACCEPT
#iptables -F
####################################################################
