#!/bin/bash
#1)
#Проверка, установлен ли докер
rpm -qa | grep docker

#Добавить официальный репозиторий Docker, загрузить последнюю версию Docker и установить
curl -fsSL https://get.docker.com/ | sh

#Запустите демон, добавить в автозапуск, проверить статус
systemctl start docker && systemctl enable docker && systemctl status docker


#3)
#Чтобы воспользоваться образом на другом компьютере, установи докер, затем:
rm -rf /tmp/dockerp
cat <<EOF>> /tmp/dockerp
XLJSaSR4rQpy
EOF
cat /tmp/dockerp | docker login --username aboltykhov --password-stdin

#Скачиваем и запускаем образ
docker pull aboltykhov/albo-nginx:nginx && docker run -d -p 80:80 aboltykhov/albo-nginx:nginx && docker ps -a


#4)
#Удалить контейнер, можно через пробел несколько <CONTAINER ID>
#docker stop <CONTAINER ID>
#docker rm <CONTAINER ID>
