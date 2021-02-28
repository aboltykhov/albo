

#!/bin/bash
yum install -y wget
cd /tmp/
wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz

#Распакуем архив
tar zxvf node_exporter-*.linux-amd64.tar.gz
cd node_exporter-*.linux-amd64

#Копируем исполняемый файл в bin:
cp node_exporter /usr/local/bin/

#Создаем пользователя nodeusr от которого будем запускать prometheus без домашней директории
useradd --no-create-home --shell /bin/false nodeusr

#Задаем владельца для исполняемого файла
chown -R nodeusr:nodeusr /usr/local/bin/node_exporter
#####################################################################
#Автозапуск
#Создаем файл node_exporter.service и копируем строки ВНИМАТЕЛЬНЕЕ!
cat <<EOF >> /etc/systemd/system/node_exporter.service

[Unit]
Description=Node Exporter Service
Wants=network.target
After=network.target

[Service]
User=nodeusr
Group=nodeusr
Type=simple
ExecStart=/usr/local/bin/node_exporter
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
#####################################################################
#Задаем владельца для исполняемого файла
chown -R nodeusr:nodeusr /usr/local/bin/node_exporter

#Перечитываем конфигурацию systemd:
systemctl daemon-reload && systemctl enable node_exporter && systemctl start node_exporter 

#Показать порты
#ss -tnlp

#Установить targets_с_node_exporter_в_prometheus
cd /tmp/dz_itog
./targets-node-setup.sh


