#!/bin/bash
#Предварительно скрипт проверяет возможность своей работы от пользователя
if [[ $UID -ne 0 ]]; then
echo "Скрипт требуется запустить в привилегированном режиме sudo или от пользователя root"
exit 1; fi

#Установить утилиту для загрузки файлов
yum install -y wget
cd /tmp/
wget https://dl.grafana.com/oss/release/grafana-7.4.2-1.x86_64.rpm

#Скачать Grafana во временный каталог и установить
yum -y install grafana-7.4.2-1.x86_64.rpm

#Перечитываем конфигурацию, добавляем в автозапуск и запускаем службу
systemctl daemon-reload && systemctl enable grafana-server && systemctl start grafana-server

#Удалить установочный пакет 
rm -rf /tmp/grafana-*

#Установить поэтапно Prometheus
cd /tmp/albo/2-server-master
./4-prometheus-setup.sh

