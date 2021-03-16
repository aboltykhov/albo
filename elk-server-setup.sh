#!/bin/bash3
cd /tmp/dz_itog/
./selinux-off.sh

#Создать файл ssh ключей для github.com в автозапуске
rm -rf /etc/ssh/ssh_config.d/github.com.conf
cat <<EOF > /etc/ssh/ssh_config.d/github.com.conf
Host github.com
    HostName github.com
    IdentityFile /etc/ssh/ssh_host_rsa_key
EOF

#Права на файл ключей ssh
chmod 644 /etc/ssh/ssh_config.d/github.com.conf
ssh -T git@github.com

#1)
#Добавление репозитория репозитори dz_elk_server
#Установить и подготовить git
yum -y install git
git config --global user.name "Alexey Boltykhov"
git config --global user.email aboltykhov@mail.ru
git config --global core.editor vi
cd /tmp/ && mkdir dz_elk_server && cd dz_elk_server
git init && git remote add origin git@github.com:aboltykhov/dz_elk_server.git
git config pull.rebase false
git pull origin main && ls -lh


#2)
#Обновим базу данных пакетов и установим пакет явы по умолчанию
yum -y install epel-release && yum check-update && yum -y install java
echo && java -version && echo

#Импортировать открытый ключ GPG  для Elasticsearch, Kibana, Logstash
rpm --import http://packages.elastic.co/GPG-KEY-elasticsearch
rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch

#Копировать репозитории для установки Elasticsearch, Kibana, Logstash
cp -a /tmp/dz_elk_server/server/etc/yum.repos.d/* /etc/yum.repos.d/

#Обновить кеш репозиториев
dnf makecache 

#Установить Elasticsearch, Kibana, Logstash
yum -y install elasticsearch kibana logstash

#Запустить Elasticsearch и добавить в аутозапуск
systemctl start elasticsearch && systemctl enable elasticsearch

#Запустить Kibana и добавить в аутозапуск
systemctl start kibana && chkconfig kibana on


#3)
#Разворачиваем бекап dz_elk_server
#Ключ -a копировать содежимое с атрибутами
rm -rf /etc/nginx/nginx.conf*
rm -rf /etc/nginx/conf.d/kibana.conf
rm -rf /etc/elasticsearch/elasticsearch.yml
rm -rf /etc/kibana/kibana.yml

cp -a /tmp/dz_elk_server/server/etc/nginx/nginx.conf* /etc/nginx/
cp -a /tmp/dz_elk_server/server/etc/nginx/conf.d/kibana.conf /etc/nginx/conf.d/
cp -a /tmp/dz_elk_server/server/etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/
cp -a /tmp/dz_elk_server/server/etc/kibana/config/kibana.yml /etc/kibana/
cp -a /tmp/dz_elk_server/client01/etc/logstash/conf.d/* /etc/logstash/
cp -a /tmp/dz_elk_server/client01/etc/filebeat/* /etc/filebeat/

#Проверь конфигурацию Logstash
service logstash start && service logstash status

#Перезапусти и включи Logstash, чтобы изменения конфигурации вступили в силу
systemctl restart logstash && chkconfig logstash on

#4)
#Загрузить информационные панели Kibana
#Загрузите образец архива информационных панелей в свой домашний каталог
cd /tmp/
curl -L -O https://download.elastic.co/beats/dashboards/beats-dashboards-1.1.0.zip

#Установить unzip и распаковать архив с дашбордами
yum -y install unzip && unzip beats-dashboards-*.zip

#Загрузите образцы панелей мониторинга, визуализаций и шаблоны индекса Beats в Elasticsearch
cd beats-dashboards-1.1.0
./load.sh

#5)
#Загрузить шаблон индекса Filebeat в Elasticsearch
cd /tmp/
curl -O https://gist.githubusercontent.com/thisismitch/3429023e8438cc25b86c/raw/d8c479e2a1adcea8b1fe86570e42abab0f10f364/filebeat-index-template.json
curl -XPUT 'http://localhost:9200/_template/filebeat?pretty' -d@filebeat-index-template.json

#Теперь, когда наш сервер ELK готов получать данные Filebeat, перейдем к настройке Filebeat на каждом клиентском сервере
cd /tmp/dz_itog/
./elk-client-filebeat.sh

