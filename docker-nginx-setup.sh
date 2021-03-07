#ПРЕЖДЕ! Должен быть подготовлен httpd (apache) на основном сервере
#################################################################
#!/bin/bash
#Предварительно скрипт проверяет возможность своей работы от пользователя
if [[ $UID -ne 0 ]]; then
echo "Скрипт требуется запустить в привилегированном режиме sudo или от пользователя root"
exit 1; fi

#1)
#Проверка, установлен ли докер
rpm -qa | grep docker

#Добавить официальный репозиторий Docker, загрузить последнюю версию Docker и установить
#Ключ -f не выводить ошибок при открытии страницы
#Ключ -L повторный запрос страницы, в случае если страницу переместили
#Ключ -sS показать сообщения об ошибке в случае сбоя
curl -fsSL https://get.docker.com/ | sh

#Запустите демон, добавить в автозапуск и проверить статус
systemctl start docker && systemctl enable docker && systemctl status docker


#2)
#Чтобы воспользоваться образом на другом компьютере, установи докер, затем:
#Ввести учетные данные, создав файл с паролем без вывода в терминал
rm -rf /tmp/dockerp
cat <<EOF > /tmp/dockerp
XLJSaSR4rQpy
EOF
cat /tmp/dockerp | docker login --username aboltykhov --password-stdin

#Скачиваем и запускаем образ albo-nginx с измененным конфигом для балансировки портов
docker pull aboltykhov/albo-nginx:nginx && docker run -d -p 80:80 aboltykhov/albo-nginx:nginx && docker ps -a
#################################################################
#Удалить контейнер, можно через пробел несколько <CONTAINER ID>
#docker ps -a
#docker stop <CONTAINER ID>
#docker rm <CONTAINER ID>
#################################################################

#Установить MySQL слейв, для репликации БД
cd /tmp/dz_itog
./new-sql-server-slave.sh


