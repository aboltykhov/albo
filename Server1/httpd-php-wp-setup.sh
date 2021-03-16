#!/bin/bash
#Предварительно скрипт проверяет возможность своей работы от пользователя
if [[ $UID -ne 0 ]]; then
echo "Скрипт требуется запустить в привилегированном режиме sudo или от пользователя root"
exit 1; fi

#Создать файл ssh ключей для github.com в автозапуске
rm -rf /etc/ssh/ssh_config.d/github.com.conf
cat <<EOF > /etc/ssh/ssh_config.d/github.com.conf
Host github.com
    HostName github.com
    IdentityFile /etc/ssh/ssh_host_rsa_key
EOF

#Права на файл ключей ssh
chmod 644 /etc/ssh/ssh_config.d/github.com.conf
echo && echo && ssh -T git@github.com

#Устанавка и запуск апача
#Ключ -y отвечает Да на установку
yum -y install httpd && sudo systemctl enable httpd && sudo systemctl start httpd

#Установка, подготовка git и добавление репозитория веб-сервера
#Ключ -y отвечает Да на установку
yum -y install git
git config --global user.name "Alexey Boltykhov"
git config --global user.email aboltykhov@mail.ru
git config --global core.editor vi
git config pull.rebase false
rm -rf /tmp/dz_web_server/
cd /tmp/ && mkdir dz_web_server && cd /tmp/dz_web_server

#Скачать бекап веб-сервера из репозитория,
git init && git remote add origin git@github.com:aboltykhov/dz_web_server.git
git pull origin main

#Добавление пакетов php 
yum install -y php php-mysqlnd php-json php-pdo php-fpm php-opcache php-gd php-xml php-mbstring php-bcmath php-odbc php-pear php-xmlrpc php-soap
systemctl start php-fpm && systemctl enable php-fpm

#Создаем папки сайтов для примера
rm -rf  /var/www/8080 /var/www/8081 /var/www/8082
mkdir /var/www/8080 /var/www/8081 /var/www/8082

#Разворачиваем бекап
#Ключ -a копировать содежимое с атрибутами
cp -a /tmp/dz_web_server/web.bak/var/www/8080/* /var/www/8080/
cp -a /tmp/dz_web_server/web.bak/var/www/8081/* /var/www/8081/
cp -a /tmp/dz_web_server/web.bak/var/www/8082/* /var/www/8082/
cp -a /tmp/dz_web_server/web.bak/var/www/html/* /var/www/html/

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
setenforce 0
systemctl restart httpd && systemctl status httpd

#Скачать бекап итоговой работы из репозитория
rm -rf /tmp/dz_itog/
cd /tmp/ && mkdir dz_itog && cd dz_itog
git init && git remote add origin git@github.com:aboltykhov/dz_itog.git
git config pull.rebase false
git pull origin main

#Показать ip-адреса хоста
echo && hostname -I && echo 

#Установить MySQL 
cd /tmp/dz_itog/
./new-sql-server-master.sh

