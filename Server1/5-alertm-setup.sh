#!/bin/bash
#Строки с решеткой кроме первой - комментарии
yum install -y wget
cd /tmp/
wget https://github.com/prometheus/alertmanager/releases/download/v0.21.0/alertmanager-0.21.0.linux-amd64.tar.gz

#Создаем каталоги в которые скопируем файлы  alertmanager
mkdir /etc/alertmanager /var/lib/prometheus/alertmanager
tar zxvf alertmanager-*.linux-amd64.tar.gz
cd alertmanager-*.linux-amd64

#Распределяем файлы по каталогам
cp alertmanager amtool /usr/local/bin/ && cp alertmanager.yml /etc/alertmanager

#Создаем пользователя от которого будем запускать alertmanager без домашней директории 
#и без возможности входа в консоль сервера
useradd --no-create-home --shell /bin/false alertmanager

#Задаем владельца для каталогов, которые мы создали на предыдущем шаге
chown -R alertmanager:alertmanager /etc/alertmanager /var/lib/prometheus/alertmanager

#Задаем владельца для скопированных файлов
chown alertmanager:alertmanager /usr/local/bin/{alertmanager,amtool}
#####################################################################
#Создаем файл автозапуска alertmanager.service
rm -rf /etc/systemd/system/alertmanager.service
cat <<EOF > /etc/systemd/system/alertmanager.service
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
#Задаем владельца для исполняемого файла, повторно
chown alertmanager:alertmanager /usr/local/bin/{alertmanager,amtool}

#Перечитываем конфигурацию
systemctl daemon-reload && systemctl enable alertmanager && systemctl start alertmanager

#Показать порты
echo && ss -tnlp && echo

#Установить node_exporter
cd /tmp/dz_itog/Server1
./6-node-exporter-setup.sh

