#ПРЕЖДЕ! Должен быть подготовлен httpd (apache) на основном сервере
#################################################################
#!/bin/bash
#Предварительно скрипт проверяет возможность своей работы от пользователя
if [[ $UID -ne 0 ]]; then
echo "Скрипт требуется запустить в привилегированном режиме sudo или от пользователя root"
exit 1; fi

#1)
#Добавить официальный репозиторий Docker, загрузить последнюю версию Docker и установить
#Ключ -f не выводить ошибок при открытии страницы
#Ключ -L повторный запрос страницы, в случае если страницу переместили
#Ключ -sS показать сообщения об ошибке в случае сбоя
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
curl -fsSL https://get.docker.com/ | sh
yum update && yum -y install yum-utils docker-ce docker-ce-cli containerd.io

#Добавить прав пользователю для управления докером без привелегий
#usermod -aG docker <username>
usermod -aG docker $SUDO_USER
usermod -aG docker adminroot

#Запустить докер и добавить в автозапуск
systemctl start docker && systemctl enable docker && systemctl status docker

#2)
#Скачиваем Docker Compose
cd /tmp
curl -L "https://github.com/docker/compose/releases/download/1.28.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

#Демаем файл docker-compose исполняемым и создаем симлинк для простоты запуска
rm -rf /usr/bin/docker-compose
chmod +x /usr/local/bin/docker-compose && ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

#Запускаем стек elk, filebeat для мониторинга nginx в Docker
cd /tmp/albo/0-elk-filebeat-nginx/
docker-compose up --build
#docker-compose up

#Установить MySQL слейв для репликации БД
cd /tmp/albo/1-server-slave
./2-new-sql-server-slave.sh
#################################################################
#Удалить контейнер, удалить несколько через пробел
#
#docker rm <CONTAINER ID>
#
#Остановить все контейнеры
#docker stop $(docker ps -a -q)
#
#Удалить все Docker контейнеры
#docker rm $(docker ps -a -q)
#
#Удалить все образы принудительно
#docker rmi -f $(docker images -q)
#################################################################
