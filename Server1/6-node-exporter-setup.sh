#!/bin/bash
#Предварительно скрипт проверяет возможность своей работы от пользователя
if [[ $UID -ne 0 ]]; then
echo "Скрипт требуется запустить в привилегированном режиме sudo или от пользователя root"
exit 1; fi

#Установить утилиту для загрузки файлов
yum install -y wget
cd /tmp/
wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz

#Распакуем архив
tar zxvf node_exporter-*.linux-amd64.tar.gz
cd node_exporter-*.linux-amd64

#Копируем исполняемый файл в bin
cp node_exporter /usr/local/bin/

#Создать пользователя без домашней директории и без возможности входа в консоль сервера 
#От которого запускается node_exporter
useradd --no-create-home --shell /bin/false nodeusr

#Сделать пользователя владельцем исполняемого файла
chown -R nodeusr:nodeusr /usr/local/bin/node_exporter
#####################################################################
#Создаем файл автозапуска node_exporter.service
rm -rf /etc/systemd/system/node_exporter.service
cat <<EOF > /etc/systemd/system/node_exporter.service
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
#Задаем владельца для исполняемого файла, повторно
chown -R nodeusr:nodeusr /usr/local/bin/node_exporter

#Перечитываем конфигурацию systemd:
sudo systemctl daemon-reload && sudo systemctl enable node_exporter && sudo systemctl start node_exporter 

#Удалить установочный пакет 
rm -rf /tmp/node_exporter-*

#Показать порты
echo && ss -tnlp && echo

#Установить targets_с_node_exporter_в_prometheus
cd /tmp/albo/Server1
./7-targets-node-setup.sh

