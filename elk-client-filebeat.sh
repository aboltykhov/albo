#!/bin/bash
#На клиентском сервере установить пакет Filebeat
#Добавление репозитория репозитори dz_elk_server
cd /tmp/ && mkdir dz_elk_server && cd dz_elk_server
git init && git remote add origin git@github.com:aboltykhov/dz_elk_server.git
git pull origin main && ls -lh

sudo su
rpm --import http://packages.elastic.co/GPG-KEY-elasticsearch
rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
cat << EOF > /etc/yum.repos.d/elastic-beats.repo
[elastic-7.x]
name=Elastic repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

#На клиентском сервере установить Filebeat
yum -y install filebeat

#На всякий случай бекапнуть конфиг
cp -a /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.bak

#Настроить конфиг Filebeat для подключения к Logstash
cp -a /tmp/dz_elk_server/server/etc/filebeat/filebeat.yml /etc/filebeat/

systemctl enable filebeat && chkconfig --add filebeat
