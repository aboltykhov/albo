#!/bin/bash
#Предварительно скрипт проверяет возможность своей работы от пользователя
if [[ $UID -ne 0 ]]; then
echo "Скрипт требуется запустить в привилегированном режиме sudo или от пользователя root"
exit 1; fi

#Устанавка и запуск апача
#Ключ -y отвечает Да на установку
sudo yum -y install httpd && sudo systemctl enable httpd && sudo systemctl start httpd

#Установка пакетов php
sudo yum install -y php php-mysqlnd php-json php-pdo php-fpm php-opcache php-gd php-xml php-mbstring php-bcmath php-odbc php-pear php-xmlrpc php-soap
sudo systemctl start php-fpm && sudo systemctl enable php-fpm

#Скачать репозиторий веб-сервера
rm -rf /tmp/dz_web_server/
cd /tmp/
git clone https://github.com/aboltykhov/dz_web_server.git
cd /tmp/dz_web_server/

#Создать папки сайтов для примера
rm -rf  /var/www/808* /var/www/html/ && echo
rm -rf  /etc/httpd/conf.d/808* && echo
mkdir /var/www/8080 /var/www/8081 /var/www/8082 /var/www/html/ && echo

#Разворачиваем бекап
#Ключ -a копировать содежимое с атрибутами
cp -a /tmp/dz_web_server/web/var/www/8080/* /var/www/8080/ && echo
cp -a /tmp/dz_web_server/web/var/www/8081/* /var/www/8081/ && echo
cp -a /tmp/dz_web_server/web/var/www/8082/* /var/www/8082/ && echo
cp -a /tmp/dz_web_server/web/var/www/html/* /var/www/html/ && echo

cp -a /tmp/dz_web_server/web/etc/httpd/conf.d/8080.conf /etc/httpd/conf.d/ && echo
cp -a /tmp/dz_web_server/web/etc/httpd/conf.d/8081.conf /etc/httpd/conf.d/ && echo
cp -a /tmp/dz_web_server/web/etc/httpd/conf.d/8082.conf /etc/httpd/conf.d/ && echo
rm -rf /etc/httpd/conf/httpd.conf
cp -a /tmp/dz_web_server/web/etc/httpd/conf/httpd.* /etc/httpd/conf/ && echo

#Установить утилиту для загрузки файлов
yum -y install wget

#Подготовка CMS WordPress 
cd /tmp/
wget http://wordpress.org/latest.tar.gz && tar zvxf latest.tar.gz -C /var/www/html/ && echo
mkdir /var/www/html/wordpress/wp-content/uploads
cd /var/www/html/wordpress/ 
rm -rf /var/www/html/wordpress/wp-config.php
cp -a /tmp/dz_web_server/web/var/www/html/wordpress/wp-config.php /var/www/html/wordpress/
chown -R apache:apache /var/www/html/wordpress/
rm -Rf /tmp/wordpress/ && rm -Rf /tmp/latest.tar.gz

#Перечитать конфигурацию и показать статус
sudo systemctl restart httpd && systemctl status httpd

#Скачать бекап итоговой работы из репозитория
rm -rf /tmp/albo/
cd /tmp/
git clone https://github.com/aboltykhov/albo.git

#Показать ip-адреса хоста
echo && hostname -I && echo 

#Установить MySQL 
cd /tmp/albo/Server1
./2-new-sql-server-master.sh

