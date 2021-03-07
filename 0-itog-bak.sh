#!/bin/bash
#Переходим в каталог
cd /tmp/dz_itog

#Переключаемся на нашу ветку
git checkout main

#Добавлем весь каталог в отслеживание
git add -A

git commit -m "Скрипты итоговой работы для серверов https://websa.advancedhosting.com/"

#Добавляем репозиторий на github.com
git remote add origin git@github.com:aboltykhov/dz_itog.git

#Отправляем изменения
git push -u origin main
