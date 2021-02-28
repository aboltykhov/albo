
#!/bin/bash
cd /tmp/
yum install -y wget
wget https://github.com/prometheus/prometheus/releases/download/v2.20.1/prometheus-2.20.1.linux-amd64.tar.gz

#Создаем каталоги в которые затем скопируем файлы для prometheus
mkdir /etc/prometheus && mkdir /var/lib/prometheus
tar zxvf prometheus-*.linux-amd64.tar.gz
cd prometheus-*.linux-amd64

#Распределяем файлы по каталогам
cp prometheus promtool /usr/local/bin/ | cp -r console_libraries consoles prometheus.yml /etc/prometheus

#Создаем пользователя от которого будем запускать prometheus без домашней директории 
#и без возможности входа в консоль сервера
useradd --no-create-home --shell /bin/false prometheus

#Задаем владельца каталогов, которые мы создали на предыдущем шаге:
chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

#Задаем владельца для скопированных файлов:
chown prometheus:prometheus /usr/local/bin/{prometheus,promtool}
#####################################################################
#Для автоматического старта Prometheus создадим новый юнит в systemd
cat <<EOF >> /etc/systemd/system/prometheus.service

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
#Задать владельца на папку
chown -R prometheus:prometheus /var/lib/prometheus

#Перечитываем конфигурацию
systemctl daemon-reload && systemctl enable prometheus && systemctl start prometheus

#Показать порты
#ss -tnlp

#Установить Alertmanager
cd /tmp/dz_itog
./alertm-setup.sh


