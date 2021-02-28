#!/bin/bash
#В комментариях копия условий домашнего задания
#Предварительно скрипт проверяет возможность своей работы от пользователя
#который его запустил и говорит что нужно сделать чтобы скрипт работал.

if [[ $UID -ne 0 ]]; then
echo "Скрипт требуется запустить в привилегированном режиме sudo или от пользователя root"
exit 1; fi

#Необходимо написать скрипт, который проверяет систему на предмет
#работы службы selinux а именно: проверяет включена ли на данный момент selinux

if sestatus | grep "SELinux status:" | grep -q "disabled"; then
echo "SELinux выключена"
elif sestatus | grep "SELinux status:" | grep -q "enabled"; then
echo "SELinux включена"; fi

#активирована ли selinux в конфиге?

if grep -q "SELINUX=enforcing" /etc/selinux/config; then
echo "В файле конфигурации SELinux активирован"
se_status_conf="enforcing"
elif grep -q "SELINUX=permissive" /etc/selinux/config; then
echo "В файле конфигурации SELinux включено ведение лога действий"
se_status_conf="permissive"
elif grep -q "SELINUX=disabled" /etc/selinux/config; then
echo "В файле конфигурации SELinux деактивирован"
se_status_conf="disabled"; fi

#выдает собранную информацию в виде диалога:
#selinux работает/не работает, в конфиге активирована/не активирована
#включить/выключить selinux?
#активировать/дизактивировать selinux в конфиге

if [ "$se_status_conf" == "disabled" ]; then
read -p 'Включить SELinux в конфигурационном файле y/n? ' line
if [[ $line == 'y' ]]; then
sed -i 's/SELINUX=disabled/SELINUX=enforcing/g' /etc/selinux/config
echo "SELinux включенна. Для завершения настройки перезагрузите систему"
elif [[ $line == 'n' ]]; then
echo "Действие отменено"; fi
else
read -p 'Выключить SELinux в конфигурационном файле y/n? ' line
if [[ $line == 'y' ]]; then
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
echo "SELinux выключенна. Для завершения настройки перезагрузите систему";
elif [[ $line == 'n' ]]; then
echo "Действие отменено"; fi
fi

#Перезагрузить систему?
read -p 'Перезагрузить систему y/n? ' reboot1
if [ $reboot1 == 'y' ]; then
echo "Процесс перезагрузки запущен..."
reboot
elif [ $reboot1 == 'n' ]; then
echo "Действие отменено"; fi
