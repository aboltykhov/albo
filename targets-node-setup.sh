

#!/bin/bash
#Строки с решеткой кроме первой - комментарии
#На сервере где установлен прометеус
#бекапируем и редактируем конфиг prometheus
cp /etc/prometheus/prometheus.yml /etc/prometheus/prometheus.yml.bak
#####################################################################
#В файлах yml важны отступы
#Подключим правило добавив файл alert.rules.yml в конфиг prometheus
rm -f /etc/prometheus/prometheus.yml
cat <<EOF >> /etc/prometheus/prometheus.yml

# my global config
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"
  - "alert.rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:

  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
      
    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

  - job_name: 'node_exporter_clients'
    scrape_interval: 5s
    static_configs:
#      - targets: ['localhost:9100','185.177.95.17:9100']
      - targets: ['localhost:9100','10.0.0.2:9100','10.0.0.3:9100']
EOF
#####################################################################
#Отображение тревог
#Простое правило, реагирующее на недоступность клиента
#Создадим файл с правилом
rm -rf /etc/prometheus/alert.rules.yml
cat <<EOF >> /etc/prometheus/alert.rules.yml

groups:
- name: alert.rules
  rules:
  - alert: InstanceDown
    expr: up == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      description: '{{ $labels.instance }} of job {{ $labels.job }} has been down
        for more than 1 minute.'
      summary: Instance {{ $labels.instance }} down
EOF
#####################################################################
#Пересоздаем службу prometheus.service
rm -f /etc/systemd/system/prometheus.service
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
#Перезагружаем и провермяем prometheus
systemctl daemon-reload && systemctl restart prometheus && systemctl status prometheus

#Показать порты
ss -tnlp

