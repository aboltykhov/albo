#!/bin/bash
#Скачать Grafana во временный каталог и установить
cd /tmp/
wget https://dl.grafana.com/oss/release/grafana-7.4.2-1.x86_64.rpm
yum -y install grafana-7.4.2-1.x86_64.rpm

#Перечитываем конфигурацию, добавляем в автозапуск и запускаем службу
sudo systemctl daemon-reload && sudo systemctl enable grafana-server && sudo systemctl start grafana-server

#Удалить установочный пакет 
rm -rf /tmp/grafana-*

#Установить поэтапно Prometheus
cd /tmp/albo/Server1
./4-prometheus-setup.sh

