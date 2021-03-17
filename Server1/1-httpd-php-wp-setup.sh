#!/bin/bash
#Предварительно скрипт проверяет возможность своей работы от пользователя
if [[ $UID -ne 0 ]]; then
echo "Скрипт требуется запустить в привилегированном режиме sudo или от пользователя root"
exit 1; fi

#Устанавка и запуск апача
#Ключ -y отвечает Да на установку
yum -y install httpd && sudo systemctl enable httpd && sudo systemctl start httpd

#Установка, подготовка git и добавление репозитория веб-сервера
#Ключ -y отвечает Да на установку
yum -y install git
rm -rf /tmp/dz_web_server/
git clone https://github.com/aboltykhov/dz_web_server.git
cd /tmp/dz_web_server/

#Добавление пакетов php 
yum install -y php php-mysqlnd php-json php-pdo php-fpm php-opcache php-gd php-xml php-mbstring php-bcmath php-odbc php-pear php-xmlrpc php-soap
systemctl start php-fpm && systemctl enable php-fpm

#Создаем папки сайтов для примера
rm -rf  /var/www/8080 /var/www/8081 /var/www/8082 /var/www/html/
mkdir /var/www/8080 /var/www/8081 /var/www/8082 /var/www/html/

#Разворачиваем бекап
#Ключ -a копировать содежимое с атрибутами
cp -a /tmp/dz_web_server/web.bak/var/www/8080/* /var/www/8080/ && echo
cp -a /tmp/dz_web_server/web.bak/var/www/8081/* /var/www/8081/ && echo
cp -a /tmp/dz_web_server/web.bak/var/www/8082/* /var/www/8082/ && echo
cp -a /tmp/dz_web_server/web.bak/var/www/html/* /var/www/html/ && echo

cp -a /tmp/dz_web_server/web.bak/etc/httpd/conf.d/8080.conf /etc/httpd/conf.d/
cp -a /tmp/dz_web_server/web.bak/etc/httpd/conf.d/8081.conf /etc/httpd/conf.d/
cp -a /tmp/dz_web_server/web.bak/etc/httpd/conf.d/8082.conf /etc/httpd/conf.d/
rm -rf /etc/httpd/conf/httpd.conf
cp -a /tmp/dz_web_server/web.bak/etc/httpd/conf/httpd.* /etc/httpd/conf/

#Подготовка CMS WordPress 
cd /tmp/
wget http://wordpress.org/latest.tar.gz && tar zvxf latest.tar.gz -C /var/www/html/
mkdir /var/www/html/wordpress/wp-content/uploads
cd /var/www/html/wordpress/
rm -rf /var/www/html/wordpress/wp-config.php
cp -a /tmp/dz_web_server/web.bak/var/www/html/wordpress/wp-config.php /var/www/html/wordpress/
chown -R apache:apache /var/www/html/wordpress/
rm -Rf /tmp/wordpress/ && rm -Rf /tmp/latest.tar.gz

#Перечитать конфигурацию и показать статус
systemctl restart httpd && systemctl status httpd

#Скачать бекап итоговой работы из репозитория
rm -rf /tmp/dz_itog/
cd /tmp/
git clone https://github.com/aboltykhov/dz_itog.git

#Показать ip-адреса хоста
echo && hostname -I && echo 

#Установить MySQL 
cd /tmp/dz_itog/Server1
./2-new-sql-server-master.sh

