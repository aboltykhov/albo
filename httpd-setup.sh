
#!/bin/bash
#Создать файл ssh ключей для github.com в автозапуске
cat <<EOF >> /etc/ssh/ssh_config.d/github.com.conf
Host github.com
    HostName github.com
    IdentityFile /etc/ssh/ssh_host_rsa_key
EOF

#Права на файл ключей ssh
chmod 600 /etc/ssh/ssh_config.d/github.com.conf

#Устанавка и запуск апача
#Ключ -y отвечает Да на установку
sudo yum -y install httpd && sudo systemctl start httpd && sudo systemctl enable httpd

#Подготовка git
mkdir dz_web_server
cd dz_web_server
git init

#Добавляем нужный репозиторий
git remote add origin git@github.com:aboltykhov/dz_web_server.git

#Скачать бекап,
#Если не скачивает, проверить название ветки, в моем случае main
git pull origin main

#Разворачиваем бекап
mkdir /var/www/8080 /var/www/8081 /var/www/8082

cp -a web.bak/var/www/8080/index.html /var/www/8080
cp -a web.bak/var/www/8081/index.html /var/www/8081
cp -a web.bak/var/www/8082/index.html /var/www/8082

cp -a web.bak/etc/httpd/conf.d/8080.conf /etc/httpd/conf.d/
cp -a web.bak/etc/httpd/conf.d/8081.conf /etc/httpd/conf.d/
cp -a web.bak/etc/httpd/conf.d/8082.conf /etc/httpd/conf.d/
cp -a web.bak/etc/httpd/conf/httpd.* /etc/httpd/conf/

#Перечитать конфигурацию и показать статус
systemctl restart httpd && systemctl status httpd

