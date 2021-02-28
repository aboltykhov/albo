

#!/bin/bash
yum install -y wget
cd /tmp/
wget https://github.com/prometheus/alertmanager/releases/download/v0.21.0/alertmanager-0.21.0.linux-amd64.tar.gz

#Создать каталоги для alertmanager
mkdir /etc/alertmanager /var/lib/prometheus/alertmanager
ls -l /etc/alertmanager && ls -l /var/lib/prometheus/alertmanager

#Распределяем файлы по каталогам
tar zxvf alertmanager-*.linux-amd64.tar.gz
cd alertmanager-*.linux-amd64
cp alertmanager amtool /usr/local/bin/ && cp alertmanager.yml /etc/alertmanager

#Создаем пользователя alertmanager от которого будем запускать prometheus без домашней директории 
#и без возможности входа в консоль сервера
useradd --no-create-home --shell /bin/false alertmanager

#Задаем владельца для каталогов, которые мы создали на предыдущем шаге
chown -R alertmanager:alertmanager /etc/alertmanager /var/lib/prometheus/alertmanager

#Задаем владельца для скопированных файлов
chown alertmanager:alertmanager /usr/local/bin/{alertmanager,amtool}
#####################################################################
#Создаем файл автозапуска alertmanager.service
cat <<EOF >> /etc/systemd/system/alertmanager.service

[Unit]
Description=Alertmanager Service
After=network.target

[Service]
EnvironmentFile=-/etc/default/alertmanager
User=alertmanager
Group=alertmanager
Type=simple
ExecStart=/usr/local/bin/alertmanager \
          --config.file=/etc/alertmanager/alertmanager.yml \
          --storage.path=/var/lib/prometheus/alertmanager \
          $ALERTMANAGER_OPTS
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
#####################################################################
#Перечитываем конфигурацию
systemctl daemon-reload && systemctl start alertmanager && systemctl enable alertmanager 

#Показать порты
#ss -tnlp

#Установить node_exporter
cd /tmp/dz_itog
./node-exporter-setup.sh


