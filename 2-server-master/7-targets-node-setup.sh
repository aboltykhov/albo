#!/bin/bash
#Предварительно скрипт проверяет возможность своей работы от пользователя
if [[ $UID -ne 0 ]]; then
echo "Скрипт требуется запустить в привилегированном режиме sudo или от пользователя root"
exit 1; fi

#На сервере где установлен прометеус
#Бекапируем и редактируем конфиг prometheus
cp /etc/prometheus/prometheus.yml /etc/prometheus/prometheus.yml.bak
#####################################################################
#В файлах yml важны отступы
#Подключим правило добавив файл alert.rules.yml в конфиг prometheus
#Рабочее название для группы клиентов node_exporter_clients
#Несколько клиентов добавляется через запятую
rm -rf /etc/prometheus/prometheus.yml
cat <<EOF > /etc/prometheus/prometheus.yml
alerting: 
  alertmanagers: 
    - 
      static_configs: 
        - 
          targets: 
            - "localhost:9093"
global: 
  evaluation_interval: 15s
  scrape_interval: 15s
rule_files: 
  - /etc/prometheus/*.rules.yml
scrape_configs: 
  - 
    job_name: prometheus
    static_configs: 
      - 
        targets: 
          - "localhost:9090"
  - 
    job_name: node_exporter_clients
    scrape_interval: 5s
    static_configs: 
      - 
        targets: 
          - "localhost:9100"
          - "10.0.0.2:9100"
          - "10.0.0.3:9100"
EOF
#####################################################################
#Отображение тревог
#Создадим файл с правилом, реагирующее на недоступность клиента
rm -rf /etc/prometheus/alert.rules.yml
cat <<EOF > /etc/prometheus/alert.rules.yml
groups: 
  - 
    name: alert.rules
    rules: 
      - 
        alert: InstanceDown
        annotations: 
          description: "{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 1 minute."
          summary: "Instance {{ $labels.instance }} down"
        expr: "up == 0"
        for: 1m
        labels: 
          severity: critical
EOF
#####################################################################
#Сделать пользователя владельцем каталогов
chown -R prometheus:prometheus /etc/prometheus

#Перезагружаем и провермяем prometheus
systemctl daemon-reload && systemctl restart prometheus && systemctl status prometheus
#####################################################################

#Показать порты
echo && ss -tnlp && echo

#Устанавливаем службу управления доступом к портам
cd /tmp/albo/2-server-master
./8-iptables-master-import.sh

