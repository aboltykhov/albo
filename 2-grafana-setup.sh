
#!/bin/bash
#Скачать grafana во временный каталог и установить
cd /tmp/
wget https://dl.grafana.com/oss/release/grafana-7.4.2-1.x86_64.rpm
cd /tmp/
yum -y install grafana-7.4.2-1.x86_64.rpm

#Перечитываем конфигурацию, добавить в автозапуск и запустить службу
systemctl daemon-reload && systemctl start grafana-server && systemctl enable grafana-server

#Установить prometheus
cd /tmp/dz_itog
./prometheus-setup.sh
