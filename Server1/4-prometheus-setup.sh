#!/bin/bash
#Строки с решеткой кроме первой - комментарии
yum install -y wget
cd /tmp/
wget https://github.com/prometheus/prometheus/releases/download/v2.20.1/prometheus-2.20.1.linux-amd64.tar.gz

#Создаем каталоги в которые скопируем файлы для prometheus
mkdir /etc/prometheus /var/lib/prometheus
tar zxvf prometheus-*.linux-amd64.tar.gz
cd prometheus-*.linux-amd64

#Распределяем файлы по каталогам
#Ключ -r означает копировать рекурсивно
cp prometheus promtool /usr/local/bin/ && cp -r console_libraries consoles prometheus.yml /etc/prometheus

#Создать пользователя без домашней директории и без возможности входа в консоль сервера 
#От которого запускается prometheus
useradd --no-create-home --shell /bin/false prometheus

#Сделать пользователя владельцем каталогов
chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

#Сделать пользователя владельцем для скопированных файлов
chown prometheus:prometheus /usr/local/bin/{prometheus,promtool}
#####################################################################
#Для автоматического старта Prometheus создадим новый юнит в systemd
rm -rf /etc/systemd/system/prometheus.service
cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Service
After=network.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
--config.file /etc/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus/ \
--web.console.templates=/etc/prometheus/consoles \
--web.console.libraries=/etc/prometheus/console_libraries
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
#####################################################################
#Задаем владельца для исполняемого файла, повторно
chown -R prometheus:prometheus /var/lib/prometheus

#Перечитываем конфигурацию
sudo systemctl daemon-reload && sudo systemctl enable prometheus && sudo systemctl start prometheus

#Удалить установочный пакет 
rm -rf /tmp/prometheus-*

#Показать порты
echo && ss -tnlp && echo

#Установить Alertmanager
cd /tmp/albo/Server1
./5-alertm-setup.sh

