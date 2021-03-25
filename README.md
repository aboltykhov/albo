## Итоговый проект: Al Bo

### Тема: настройка серверов или восстанволение

---

- Количество серверов: 3 шт.

- Используемая ОС: CentOS 8

- Используемая сеть: 10.0.0.0/24

- Основной сервер: 10.0.0.1/24

- Сервер-реплика: 10.0.0.2/24

- Сервер-замена : 10.0.0.3/24 

---

С каждого сервера проверяем SSH подключение: 

        ssh username@ip_address -p 22

Устанавливаем и настраиваем GIT: 

        sudo yum -y install git

Скачиваем репозиторий, например в /tmp: 

        git clone https://github.com/aboltykhov/albo.git

---

> Каталог albo

>> 0-elk-filebeat-nginx		#Подкаталог: стек Elasticsearch/Logstash/Kibana/Filebeat для Docker Compose

>> 1-server-slave				#Подкаталог: сервер-реплика
>>> 1-new-sql-server-slave.sh		#Установка СУБД MySQL c настриваемой репликацией master/slave
>>> 2-node-exporter-client-setup.sh	#Установка Node Exporter для сбора метрик сервера-реплики
>>> 3-iptables-slave-import.sh		#Установка утилиты iptables для управления доступом по портам
>>> 4-docker-elk-nginx-setup.sh		#Установка стека (Elasticsearch/Logstash/Kibana) и Filebeat для мониторинга nginx в Docker
>> 

>> 2-server-master				#Подкаталог: основной сервер
>>> 1-new-sql-server-master.sh	#СУБД MySQL c настриваемой репликацией master/slave
>>> 2-httpd-php-wp-setup.sh		#Установка веб-сервера на базе LAMP, CMS WordPress
>>> 3-grafana-setup.sh			#Веб-приложение для визуализации мониторинга
>>> 4-prometheus.sh				#Установка Prometheus системы мониторинга 
>>> 5-alertm-setup.sh			#Установка Alertmanager для отправки уведоблений
>>> 6-node-exporter-setup.sh		#Установка Node Exporter для сбора метрик
>>> 7-targets-node-setup.sh		#Добавление хостов для мониторинга
>>> 8-iptables-master-import.sh	#Установка утилиты iptables для управления доступом по портам
>> 

>> sql					      	#Подкаталог: sql-запросы 
> 

---

Внутри каталога albo/1-server-slave:

---

Внутри каталога albo/2-server-master:

---

### Установка на "Сервере-реплика":

Заходим в подкаталог 1-server-slave

        ./0-selinux-off.sh #Отключаем SELinux

Перезагружаемся,

Из подкаталога 1-server-slave запускаем скрипт 

        ./1-new-sql-server-slave.sh

Установка проходит в полуавтоматическом режиме по нумерации скриптов из каталога,

Во время установки потребуется настроить компонент проверки пароля MySQL, 

Установите пароль: User1589$

---

### Установка на Основном сервере:

Заходим в подкаталог 2-server-master

        ./0-selinux-off.sh #Отключаем SELinux

Перезагружаемся,

Из подкаталога 2-server-master запускаем скрипт  

        ./1-new-sql-server-master.sh

Установка будет проходить в полуавтоматическом режиме по нумерации скриптов из каталога,

Во время установки потребуется настроить компонент проверки пароля MySQL, 

Установите пароль: User1589$

---

### На "Сервер-реплика"

В файле sql/replication-slave.sql

Указываем binlog и MASTER_LOG_POS "Основного сервера"

На "Сервер-реплика" импортируем конфигурацию

        mysql -u root --password=User1589$ < /tmp/albo/sql/replication-slave.sql

---

### На "Основном сервере"

Создать БД для CMS WordPress

        mysql -u root --password=User1589$ < /tmp/albo/sql/wp-db-user.sql

Создать таблицу в БД от имени пользователя wpuser

        mysql -u wpuser --password=WP1password$ < /tmp/albo/sql/wp-albo.sql

---

#### Сервер-реплика: готов

#### Основной сервер: готов

---

Домашняя страница Kibana http://10.0.0.2:5601 http://185.177.95.17:5601/

> Пользователь: elastic

> Пароль: changeme
