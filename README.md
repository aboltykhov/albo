####################################################

Итоговый проект: Al Bo

Чистая установка пары серверов или восстанволение 

####################################################

Используемая ОС: CentOS 8

Количество серверов: 3 шт.

####################################################

Server 1						      #Каталог содержит скрипты, порядок запуска скриптов по номеру

0.selinux-off 				    #Отключавем SELinux
1.
2.httpd-php-wp-setup	    #Установка apache/php/cms
3.
4.new-sql-server-master		#СУБД MySQL c настриваемой репликацией master



#Так как в проекте задействованы и мониторинг далее производится установка prometheus+grafana

2-grafana-setup

prometheus-setup.sh

alertm-setup.sh

node-exporter-setup.sh

targets-node-setup.sh



Server 2						      #Каталог содержит скрипты, порядок запуска скриптов по номеру

0.selinux-off					    #Отключавем SELinux
1.
2.docker-nginx-setup			#
3.
4.new-sql-server-slave		#СУБД MySQL c настриваемой репликацией slave
5.
6.node-exporter-client-setup

####################################################

3 сервер в проекте как "сервер бекапов" или "сервер-замена"

####################################################
