#!/bin/bash
#Предварительно скрипт проверяет возможность своей работы от пользователя
if [[ $UID -ne 0 ]]; then
echo "Скрипт требуется запустить в привилегированном режиме sudo или от пользователя root"
exit 1; fi

#Установить утилиту yum-config-manager 
yum -y install yum-utils

#Установить или обновить Docker из репозитория
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
    
yum update

#Добавить пользователя в группу docker для управления докером, не используя sudo
sudo usermod -aG docker $SUDO_USER

#Загрузить текущую версию Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

#Сделать файл docker-compose исполняемым
sudo chmod +x /usr/local/bin/docker-compose

#Создать символическую ссылку
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

#Скачать репозиторий docker-elk
cd /tmp/
git clone https://github.com/deviantony/docker-elk

#Запустить контейнеры ELK
cd /tmp/docker-elk
docker-compose up

#Всё!
