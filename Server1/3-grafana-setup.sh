#!/bin/bash
#Скачать Grafana во временный каталог и установить
cd /tmp/
wget https://dl.grafana.com/oss/release/grafana-7.4.2-1.x86_64.rpm
yum -y install grafana-7.4.2-1.x86_64.rpm

#Перечитываем конфигурацию, добавляем в автозапуск и запускаем службу
systemctl daemon-reload && systemctl enable grafana-server && systemctl start grafana-server

#Установить поэтапно Prometheus
cd /tmp/dz_itog/Server1
./4-prometheus-setup.sh
